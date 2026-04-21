class BankTransactionsController < ApplicationController
  before_action :set_bank_transaction, only: %i[ show edit update destroy link set_link]

  # GET /bank_transactions
  def index
    sd = Date.today.beginning_of_month - 12.months
    ed = Date.today
    if params[:date].present?
      @bank_transactions = BankTransaction.by_month(params[:date])
    else
      @bank_transactions = Current.book.bank_transactions
    end
  end

  # GET /bank_transactions/1
  def show
  end

  # GET /bank_transactions/new
  def new
    @bank_transaction = BankTransaction.new(client_id:Current.client.id,book_id:Current.book.id)
  end

  # GET /bank_transactions/1/edit
  def edit
  end

  # POST /bank_transactions
  def create
    @bank_transaction = BankTransaction.new(bank_transaction_params)
    if @bank_transaction.save
      redirect_to @bank_transaction, notice: "Bank transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /bank_transactions/1
  def update

    if @bank_transaction.update(bank_transaction_params)
      redirect_to bank_transactions_path, notice: "Bank transaction was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /bank_transactions/1
  def destroy
    @bank_transaction.destroy!
    redirect_to bank_transactions_path, notice: "Bank transaction was successfully destroyed.", status: :see_other
  end

  def link
    @splits = @bank_transaction.links 
  end
  #   # this was setup to find an un-reconciled split but for 
  #   # test it was set to y. that didn't find the 7 month check
  #   # setting it to not y found it.
  #   # try not looking for reconciled state
  #   # .where.not(reconcile_state:'y')
  #   amt = (@bank_transaction.amount * 100).round(2).to_i
  #   dtime = (Date.today - 12.months).to_time
  #   @splits = Split.where(account_id:Current.book.checking_ids)
  #     .where.not(reconcile_state:'y')
  #     .where(amount:amt)
  #     .where("updated_at > ?", dtime).includes(:entry)
  # end

  def set_link
    @bank_transaction.split_id = params[:split_id]
    flash.now[:alert] = "#{session[:bs_id]} - You have requested to link a Bank Transaction to the selected Split. Update to confirm or Cancel"
    render :edit
  end

  def preview
    @trans = BankTransaction.import_transactions
   end

  def import
  end

  def import_create
    @trans = BankTransaction.import_transactions
  end

  def upload_file
    filename = params[:file].original_filename
    unless filename.include?("Transactions-")
      redirect_to import_bank_transactions_path, alert: "Filenames for this Book must start with `Transactions-`, Reselect file.";return
    else
      csvfile = params[:file].read
    end
    if csvfile.bytes[0] == 239
      csvfile = csvfile[3..-1]
    end
    @filename = filename
    @csv = Ledger.csv_text_to_hash(csvfile)
    $csv_hash = @csv  # for preview
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_transaction
      @bank_transaction = BankTransaction.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def bank_transaction_params
      params.expect(bank_transaction: [ :client_id, :book_id, :split_id, :post_date, :type, :description, :amount ])
    end
end
