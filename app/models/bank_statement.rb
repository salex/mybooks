class BankStatement < ApplicationRecord
  acts_as_tenant(:client) ### for acts_as-tenant
  belongs_to :book

  # todo this may need to be changed (IT WAS!)to get all transactions 
  # not reconciled. still think on process
  # should be something like
  # create transactions when uploaded
  # remove when reconciled
  # would contain check that are not cleared for a while
  def transactions
    # bom = self.statement_date.beginning_of_month
    # eom = bom.end_of_month
    self.book.bank_transactions 
    #.where(post_date:[bom..eom])
  end

  def reconciled_splits
    bom = self.statement_date.beginning_of_month
    eom = bom.end_of_month 
    bs_splits = Split.where(account_id:self.book.checking_ids).where(reconcile_date:[bom..eom]).includes(:entry)
    splits = []
    bs_splits.each do |s|
      h = {}
      h[:entry_id] = s.entry.id
      h[:date] = s.entry.post_date
      h[:description] = s.entry.description
      h[:numb] = s.entry.numb
      h[:split_id]
      h[:amount] = s.amount
      h[:rstate] = s.reconcile_state
      h[:rdate] = s.reconcile_date
      h[:sid] = s.id
      splits << h
    end
    splits.sort_by!{|h| h[:date]}
  end

  def unreconciled_splits
    bom = self.statement_date.beginning_of_month
    eom = bom.end_of_month 
    bs_splits = Split.where(account_id:self.book.checking_ids).where(reconcile_state:'n').includes(:entry)
    splits = []
    bs_splits.each do |s|
      # this only gets entries/splits <= bs.eom
      unless s.entry.post_date > eom
        h = {}
        h[:entry_id] = s.entry.id
        h[:date] = s.entry.post_date
        h[:description] = s.entry.description[0..50]
        h[:numb] = s.entry.numb
        h[:split_id]
        h[:amount] = s.amount
        h[:rstate] = s.reconcile_state
        h[:rdate] = s.reconcile_date
        h[:sid] = s.id
        splits << h
      end
    end
    splits.sort_by!{|h| h[:date]}
  end

  def entry_splits
    # This is only called when there are no bank transactions
    # think you can just call and return this.checking.reconciled splits
    bom = self.statement_date.beginning_of_month
    eom = bom.end_of_month 
    entries = Entry.where(post_date:[bom..eom])
    splits = []
    entries.each do |e|
      bs_splits = e.splits.where(account_id:self.book.checking_ids).includes(:entry)
      bs_splits.each do |s|
        h = {}
        h[:entry_id] = s.entry.id
        h[:date] = s.entry.post_date
        h[:description] = s.entry.description[0..50]
        h[:numb] = s.entry.numb
        h[:split_id]
        h[:amount] = s.amount
        h[:rstate] = s.reconcile_state
        h[:rdate] = s.reconcile_date
        h[:sid] = s.id
        splits << h
      end
      # puts "DO I HAVE SPLITS #{splits}
    end
    splits.sort_by!{|h| h[:date]}
  end

  # MOVED TO INHERITED MODEL bank_ofx.rb OFX NOT used any mor
  # this is hardwired test to see if i want to allow ofx and csv
  def get_transactions
    ofx = parse_ofx
    build_transactions(ofx)
  end

  def parse_ofx
    ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
    results = Hash.new
    stmnt_from = ofx.index("<DTSTART>") #.slice(/.*?(?=\r|\n)/).strip
    get_text = ofx[stmnt_from..(stmnt_from + 50)]
    stmnt_from = get_text.slice(/.*?(?=\r|\n)/).strip

    stmnt_to = ofx.index("<DTEND>")
    get_text = ofx[stmnt_to..(stmnt_to + 50)]
    stmnt_to = get_text.slice(/.*?(?=\r|\n)/).strip

    balance = ofx.index("<BALAMT>")
    get_text = ofx[balance..(balance + 20)]
    balance = get_text.slice(/.*?(?=\r|\n)/).strip

    results[:stmnt_from] = stmnt_from
    results[:stmnt_to] = stmnt_to
    results[:balance] = balance

    tran_start = ofx.index("<BANKTRANLIST>")
    tran_end = ofx.index("</BANKTRANLIST>") -13
    # the end of banktranlist is not included
    tran_list = ofx[tran_start..tran_end]
    tran_arr = []
    arr = tran_list.split("\r\n")
    arr.each{|l| tran_arr << l.strip!}
    results[:transactions] = tran_arr[3..-1]
    # return @tran_arr\\
    results
  end

  def build_transactions(results)
    # third++ attempts
    transactions = results[:transactions]
    id = 0
    trans = {}
    transactions.each do |t|
      next if t.include?('</STMTTRN>')
      if t.include?('<STMTTRN>')
        id += 1
        trans[id] = []
        next
      end
      # cleanup kv
      kv = t.split('>')
      kv[0] = kv[0][1..-1]
      trans[id] << kv
      # set values
      case kv[0]
      when "TRNAMT"
        kv[1] = kv[1].to_f
      when "CHECKNUM"
        kv[1] = kv[1].to_i
      when "DTPOSTED"
        kv[1] = kv[1].to_date
      end
    end
    bt = Hash[trans]
  end

end
