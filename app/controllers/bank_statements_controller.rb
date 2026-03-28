class BankStatementsController < ApplicationController
  before_action :set_bank_statement, only: %i[ show edit update destroy reconcile reconciled]

  # GET /bank_statements
  def index
    @bank_statements = Current.book.bank_statements.order(:statement_date).reverse
    session[:bs_id] = nil
  end

  # GET /bank_statements/1
  def show
    @bank_transactions = BankTransaction.by_month(@bank_statement.statement_date)
    session[:bs_id] = @bank_statement.id
  end

  # GET /bank_statements/new
  def new
    @bank_statement = Current.book.bank_statement.new(client_id:Current.client.id,book_id:Current.book.id)
  end

  # GET /bank_statements/1/edit
  def edit
  end

  # POST /bank_statements
  def create
    @bank_statement = Current.book.bank_statement.new(bank_statement_params)

    if @bank_statement.save
      redirect_to @bank_statement, notice: "Bank statement was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bank_statements/1
  def update
    if @bank_statement.update(bank_statement_params)
      redirect_to @bank_statement, notice: "Bank statement was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bank_statements/1
  def destroy
    @bank_statement.destroy!
    redirect_to bank_statements_path, notice: "Bank statement was successfully destroyed.", status: :see_other
  end

  def import
  end

  def upload_file
    # puts "ITS IN UPLOAD FILE RB #{params[:file].inspect}"
    # puts "FILE NAME #{params[:file].original_filename}"
    filename = params[:file].original_filename
    unless filename.include?("Transactions-")
      redirect_to import_bank_transactions_path, alert: "Filenames for this Book must start with `Transactions-`, Reselect file.";return
    else
      csvfile = params[:file].read
    end
    # headers = csvfile.headers
    # csvfile = params[:file].read
    if csvfile.bytes[0] == 239
      csvfile = csvfile[3..-1]
    end
    @filename = filename
    @csv = Ledger.csv_text_to_hash(csvfile)
  end

  def reconcile
    session[:bs_id] = @bank_statement.id
    @bank_transactions = BankTransaction.by_month(@bank_statement.statement_date.to_s)
    if @bank_transactions.blank?
      redirect_to bank_statement_path, alert: 'There are no Bank Transactions for this statement. It has probably been reconciled'
    end
  end

  def reconciled
    # puts "PARAMS INSPECT #{params}"
    bt = BankTransaction.find(params[:ids])
    bt.each do |t|
      # puts t.inspect
      split = Split.find(t[:split_id])
      # this is a kludge that accounts for splits that have be reconciled
      # using old reconcile. It should be last day of month
      # thing on how to fix it for past, should work in future
      # bankstatement date is the 1st of the next month
      if split.reconcile_state != 'y'
        split.reconcile_state = 'y'
        split.reconcile_date = @bank_statement.statement_date.end_of_month
        split.save
        t.delete
      else
        t.delete
      end
      # puts split.inspect
    end
    redirect_to @bank_statement, notice: "Bank statement was successfully reconciled.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_statement
      @bank_statement = Current.book.bank_statements.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def bank_statement_params
      # params.require(:model).permit(ids: [])
      params.expect(bank_statement: [ :client_id, :book_id, :statement_date, :beginning_balance, :ending_balance, :summary, :reconciled_date, :json ])
    end
end
