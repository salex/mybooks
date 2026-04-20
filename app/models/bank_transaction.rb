class BankTransaction < ApplicationRecord
  belongs_to :client
  belongs_to :book
  attribute :pennies, :integer
  attribute :check, :integer
  after_initialize :set_pennies

  def set_pennies
    self.pennies = (self.amount * 100).round unless self.amount.blank?
    if self.description.include?("CK # ")
      # THIS ONLY WORKS FOR SOME CSV FILES
      # self.check = self.description[5..-1].to_i
      # more generic version, gets first integers
      self.check = self.description.scan(/\d+/).first.to_i
    end
  end

  def links
    # this was setup to find an un-reconciled split amount
    amt = self.pennies 
    dtime = (Date.today - 12.months).to_time
    @splits = Split.where(account_id:Current.book.checking_ids)
      .where.not(reconcile_state:'y') 
      .where(amount:amt)
      .where("updated_at > ?", dtime).includes(:entry)
    return @splits
  end


  def self.by_month(date)
    # puts "DATE CLASSS #{date} #{date.class}"
    if date.class == Date
      bom = date
    else
      bom = Date.parse(date).beginning_of_month
    end
    eom = bom.end_of_month
    bt = Current.book.bank_transactions.where(post_date:[bom..eom])
  end

  # NOT USED
  def self.splits_by_month(date)
    bom = Date.parse(date).beginning_of_month
    eom = bom.end_of_month
    b = Book.find 1
    splits = Split.where(account_id:b.checking_ids).where(reconcile_date:[bom..eom]).includes(:entry)
  end


  def self.import_transactions(csv_hash=nil)
    # BankTransactions have keys
    #["id","client_id","book_id","split_id","post_date",
    # "category","description","amount","check"]
    # on initial create from csv we only need
    # ["post_date","category","description","amount"]
    bts = []
    if csv_hash.nil?
      csv_hash = $csv_hash
    end
    # LOOK For debit or credit ind {$csv_hash[0..n]}"
    csv_hash.each do |t|
      bt = Current.book.bank_transactions.new
      bt.post_date = Ledger.safe_date_parse(t['Date'])
      bt.description = t['Description']
      # category or type end up in a split memo
      # will put here in category
      if t['Category'].present?
        bt.category = t['Category']
      elsif t['Type'].present?
        bt.category = t['Type']
      end
      bt.amount = t['Amount'].to_f
      # check if HAS DBCR #{t['DebitCredit'].present?}"
      # negate amount if debit
      if t['DebitCredit'].present?  && t['DebitCredit'] == 'Debit'
        bt.amount = bt.amount * -1
      end
      if t['Description'].include?("CK # ")
        bt.check = t['Description'][5..-1].to_i
      end
      bt.book_id = Current.book.id
      bt.client_id = Current.book.client_id
      bt.split_id = nil
      bts << bt
    end
    return bts #.sort_by(BankTransaction.post_date -nah comes in sorted)

  end
  # bank accounts csv formats  # not used except to define whats in each bank csv
  def self.bank_csv_fomats 
    max_h = ["AccountName", "ProcessedDate", "Description", "CheckNumber", "CreditorDebit", "Amount"]
    max_r = ["GROW CHECKING", "2026-01-02", "WITHDRAWAL POS #600216546189 MARATHON 200311 GADSDEN AL", "", "Debit", "34.07"]
    river_h = ["Date", "Type", "Description", "Category", "Amount", "Balance", "Note"]
    river_r = ["12-22-2025", "Priority Post Debit", "3500 VSA PMT DB ZEFFY DEPTAL VFW ZEFFY.COM DE", "", "-180", "4097.98",""]
    usaa_h = ["Date", "Description", "OriginalDescription", "Category", "Amount", "Status"]
    usaa_r = ["2026-01-02", "Cooks Pest", "COOKS PEST CONTROL - GA 256-355-3285 AL", "Home", "-117.00", "Posted"]
    family_h = ["AccountName", "ProcessedDate", "Description", "CheckNumber", "CreditorDebit", "Amount"]
    family_r = ["NSPIRE CHECKING", "2025-12-05", "DEPOSIT BY CHECK CHECK RECEIVED 1,248.00", "", "Credit", "1048.0"]

    banks = {
      max:{
      header:max_h,
      row:max_r,
      date:'yyyy-mm-dd'
      },
      river:{
      header:river_h,
      row:river_r,
      date:'mm-dd-yyyy'
      },
      usaa:{
      header:usaa_h,
      row:usaa_r,
      date:'yyyy-mm-dd'
      },
      family:{
      header:family_h,
      row:family_r,
      date:'yyyy-mm-dd'
      }
    }
    return banks
  end
  
end
