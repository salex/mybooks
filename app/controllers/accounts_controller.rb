class AccountsController < ApplicationController
  # allow_unauthenticated_access

  before_action :set_account, only: %i[ show edit update destroy new_child]

  # GET /accounts
  def index
    @accounts = Current.book.build_tree
    # flash[:notice] = "you opened index-table"

  end
  def index_table
    @accounts = Current.book.build_tree
    # flash.now[:notice] = "you opened index-table"
  end


  # GET /accounts/1
 
  def show
    set_recent if params[:toggle].present?
    @date = Date.today # not used but thinking
    set_param_date
    session[:current_acct] = @account.id
    render template:'accounts/ledger/show'
  end

  def filter
    set_account
    session[:current_acct] = @account.id
    set_param_date
    render turbo_stream: turbo_stream.replace(
      'ledger', partial: 'accounts/ledger/ledger', 
      locals:{from:@from,to:@to,account:@account})
  end

  # GET /accounts/new
  def new
    @account = Current.book.accounts.new
  end

  def new_child
    @parent = @account
    @account = Account.new(book_id:@parent.book_id,parent_id:@parent.id,account_type:@parent.account_type)
    render :new
  end


  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to @account, notice: "Account was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to @account, notice: "Account was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy!
    redirect_to accounts_path, notice: "Account was successfully destroyed.", status: :see_other
  end

  private
    def set_param_date
      # sets datas based on params or last transaction
      #  if params include a date from/to converted to beginning and end of month
      #  if only from will set from and to (or today of to missing)
      #  if parmans not present will get last transaction and set from to beginning of its month
      #  if from is in current month, may look back 7 days from from date
      @today = Date.today
      minus7 = @today.day < 8 ? 8  - @today.day : 0 # if in first week of month, look back 7 days
      if params[:date].present? # from month pulldown
        @date = Ledger.set_date(params[:date])
        @from = @date.beginning_of_month
        @to = @date.end_of_month
      elsif params[:from].present? # from date picker(from,to)
        @from = Ledger.set_date(params[:from])
        @to = params[:to].present? ? Ledger.set_date(params[:to]) : @today.end_of_month
      else
        # puts "HAVE SSSS #{@account.leafs}"
        last_tran = @account.last_entry_date ||= @today.beginning_of_year
        @from = last_tran.beginning_of_month
        @from -= minus7 if Ledger.dates_in_same_month(@today,@from)
        @to = @today.end_of_month
      end
    end

    # def set_param_date
    #   # sets datas based on params or last transaction
    #   #  if params include a date from/to converted to beginning and end of month
    #   #  if only from will set from and to (or today of to missing)
    #   #  if parmans not present will get last transaction and set from to beginning of its month
    #   #  if from is in current month, may look back 7 days from from date
    #   @today = Date.today
    #   minus7 = @today.day < 8 ? 8  - @today.day : 0 # if in first week of month, look back 7 days
    #   puts "IM SET #{minus7}"
    #   if params[:date].present? # from month pulldown
    #     @date = Ledger.set_date(params[:date])
    #     @from = @date.beginning_of_month
    #     @to = @date.end_of_month
    #   elsif params[:from].present? # from date picker(from,to)
    #     @from = Ledger.set_date(params[:from])
    #     @to = params[:to].present? ? Ledger.set_date(params[:to]) : @today.end_of_month
    #   else
    #     # last_tran = @account.last_entry_date
    #     last_tran = @account.entries.last.post_date
    #     @from = last_tran #.beginning_of_month
    #     # @from -= minus7 if Ledger.dates_in_same_month(@today,@from)
    #     @to = @today.end_of_month
    #     puts "IN LAST ELSE Last #{last_tran} From #{@from} To #{@to}"

    #   end
    # end

    def set_recent
      if session[:recent] && session[:recent].has_key?(@account.id.to_s)
        session[:recent].delete(@account.id.to_s) 
      else
        session[:recent][@account.id.to_s] = @account.name
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find_by(id:params[:id])
      redirect_to( accounts_path, alert:'Account not found for Current Book') if @account.blank?

    end

  
    # Only allow a list of trusted parameters through.
    def account_params
      params.expect(account: [ :client_id, :book_id, :name, :account_type, :code, :description, :placeholder, :parent_id, :level ])
    end
end
