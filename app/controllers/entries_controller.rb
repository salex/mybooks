class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]
  # before_action :require_book
  # GET /entries
  # GET /entries.json
  def index
    redirect_to accounts_path, notice:'Entries can only be accessed through Accounts'
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    # authorize Entry, :trustee?
    if params[:account_id].present?
      account = Account.find(params[:account_id])
    else 
      account = Account.new
      # ououoiuo = redirect to somewhere
    end
    @entry = Current.book.entries.new(post_date:Date.today)
    # puts "ENTRY #{@entry.inspect}"
    # puts "ACCOUNT #{account.id}"

    session[:current_acct] = account.id
    1.upto(3) do |i|
      aid = i == 1 ? account.id : nil
      splits = @entry.splits.build(reconcile_state:'n',account_id: aid, amount:0, debit:0)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /entries/1/edit
  def edit
    2.times{@entry.splits.build(reconcile_state:'n')}

  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = Current.book.entries.new(entry_params)
    # authorize Entry, :trustee?
    @bank_dup = @entry.fit_id.present?
    # TODO not used fit should be nil unless it was created from a bank transaction
    respond_to do |format|

      if @entry.valid_params?(entry_params) && @entry.save
        if @bank_dup
          @entry.bank_transaction
        end
        format.html { redirect_to redirect_path, notice: 'Entry was successfully created.' }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      if @entry.valid_params?(entry_params) && @entry.update(entry_params)
        format.html { redirect_to redirect_path, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
    rescue ActiveRecord::StaleObjectError
      respond_to do |format|
        format.html {
          flash[:alert] = "This project has been updated while you were editing. Please refresh to see the latest version."
          render :edit
        }
        format.json { render json: { error: "Stale object." } }
      end
    
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def link
    # TODO NOTUSED i think 
    # authorize Entry, :trustee?
    entry = Current.book.entries.find_by(id:params[:id])
    if entry.blank?
      redirect_to latest_ofxes_path, alert:  "ERROR Entry to link to was not found!."
      #this should not happen, but just in case
    elsif entry.fit_id.present?
      redirect_to latest_ofxes_path, alert:  "The Entry has already been linked!."
    else
      entry.link_ofx_transaction(params[:fit_id])
      # head :ok
      redirect_to latest_ofxes_path, notice: "Entry Linked to OFX fit_id"
    end

  end

  def new_entry
    bt = BankTransaction.find(params[:id])
    # puts "DDDDDD  #{params.inspect}"
    amt = (bt.amount * 100).to_i
    account = Account.find_by(name:params[:checking])
    memo = params[:memo]  
    @entry = Current.book.entries.new(
      post_date:bt.post_date,
      description:bt.description,
      numb:bt.check)
    splits = []
    1.upto(3) do |i|
      aid = i == 1 ? account.id : nil
      # set all split to nil
      splits << @entry.splits.build(reconcile_state:'n',account_id:0 , amount:0, debit:0)
    end
    # splits[0].amount = amt 
    if amt >= 0
      splits[0].debit = amt
    else
      splits[0].credit = amt * -1
    end
    splits[0].memo = memo
    splits[0].account_id = account.id


    puts "DDDDD #{@entry.splits[0].inspect }"
    # @entry.splits.build()
    # splits.amount = 123456

    # 1.upto(3) do |i|
    #   splits == @entry.splits.build(reconcile_state:'n',account_id: 0, amount:0, debit:0)
    # end
    # # puts splits.inspect
    # puts bt.amount
    # splits[0].amount = (bt.amount * 100).to_i 
    # if splits[0].amount < 0
    #   splits[0].debit = (splits[0].amount * -1) / 100
    # else
    #   splits[0].credit = (splits[0].amount / 100)
    # end

    # puts "WS SP:today #{splits[0].inspect}"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
    render template:'entries/new'
  end

  def new_bt
    # TODO NOTUSED i think 
    @entry = Current.book.entries.new(post_date:params[:date],
      fit_id:params[:id], numb:params[:check_number],
      description:params[:memo])
    amt = (params[:amount].to_i).abs
    1.upto(2) do |i|
      if i == 1
        aid = nil
        if params[:type_tran] == 'debit'
          cr = amt
          db = ''
        else
          db = amt
          cr = ''
        end
      else
        aid = nil
        if params[:type_tran] == 'debit'
          db = amt
          cr = ''
        else
          cr = amt
          db = ''
        end
      end
      splits = @entry.splits.build(reconcile_state:'c',
        account_id: aid,amount:params[:amount].to_i,debit:db,credit:cr)
    end
    @entry.splits.build(reconcile_state:'n') # add extra split
    render template:'entries/new'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def redirect_path
      if @bank_dup.present?
        latest_ofxes_path
      elsif session[:current_acct].present?
        account_path(session[:current_acct])
      else
        account_path(@entry.splits.order(:id).first.account)
      end
    end

    def set_entry
      @entry = Current.book.entries.find_by(id:params[:id])
      # puts "WAS CALLED #{@entry.blank?} #{params[:id]}"
      redirect_to( accounts_path, alert:'Entry not found for Current Book') if @entry.blank?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      # permit_all_parameters
      params.expect(entry: [ :client_id, :book_id, :numb, :post_date, :description, :fit_id, :lock_version,
        splits_attributes: [[:id,:action,:memo,:amount,:reconcile_state,:account_id,:debit,:credit,:transfer,s:_destroy]]])
    end
end
