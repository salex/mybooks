require "csv"

module Ledger
  include  ActionView::Helpers::NumberHelper

  def self.is_numeric?(s)
      !!Float(s, exception: false)
  end

  def self.to_struct(ahash)
    struct = ahash.to_struct
    struct.members.each do |m|
      struct[m] = to_struct(struct[m]) if struct[m].is_a? Hash
    end
    struct 
  end

  def self.first_days_of_months(start_date, end_date)
    return [] if start_date.nil? || end_date.nil? || start_date > end_date
   
    start_month = start_date.beginning_of_month
    # Calculate total months between start_month and end_date
    total_months = (end_date.year * 12 + end_date.month) - (start_month.year * 12 + start_month.month) + 1
   
    # Generate first day of each month by adding n months to start_month
    (0...total_months).map { |n| start_month + n.months }.reverse
  end

  # def self.fix_bs(bs)
  #   bs.each do |bs|
  #     bs['statement_date'] = Ledger.safe_date_parse(bs['statement_date']).beginning_of_month
  #     bs['reconciled_date'] = bs['statement_date'].end_of_month
  #     bs['beginning_balance'] = bs['beginning_balance'].to_i
  #     bs['ending_balance'] = bs['ending_balance'].to_i
  #     bs['client_id'] = 1
  #     bs['book_id'] = 1 
  #   end
  #   # bs = bs.sort_by { |date| bs['date'] }
  #   bs.reverse.each do |b|
  #     new_bs = BankStatement.new(b)
  #     nbs = new_bs.save
  #   end
  #   bs
  # end

  def self.safe_date_parse(dts)
    # This makes the assumption that dts (date time stamp string)
    # is going to be either MM-DD-YYYY or YYYY-MM-DD format, the only two
    # formats the I've seen in csv files
    # formats like YYYY-DD-MM DD-MM-YYYY make no sense
    # time is not defined in the dts
    begin
      # date separators allowed are - or /
      if dts.include?("/")
        date_arr = dts.split("/")
      else
        date_arr = dts.split("-")
      end
      if date_arr[2].size == 4
        dts = date_arr[2]+"-"+date_arr[0]+"-"+date_arr[1]
        # else it defaults to YYYY-MM-DD format
      end
      Date.parse(dts)
    rescue 
      "Error parsing date: #{dts}"
    end
  end

  # Next two methods not used. you can't determine type
  def self.parse_mm_dd_date(dts)
    puts "DTS #{dts}"
    dts = dts.gsub('-','/') if dts.include?('-')
    Date.strptime(dts, '%m/%d/%Y')
  end

  def self.parse_dd_mm_date(dts)
    dts = dts.gsub('-','/') if dts.include?('-')
    Date.strptime(dts, '%d/%m/%Y')
  end

  def self.hash_array_to_csv(data)
    csv_string = CSV.generate do |csv|
      csv << data.first.keys  # Add headers
      data.each do |hash|
        csv << hash.values     # Add values
      end
    end
  end

  def self.parse_ofx
    ofx_file = Rails.root.join("app/models/concerns/download.OFX")
    ofx = ofx_file.read
    myofx = MyOfx.new(ofx)
  end

  # NOT USED
  def self.csv_json(json)
    @table = JSON.parse(json)
    @header = @table[0].keys
    @values = []
    @table.each do |row|
      row_values = []
      @header.each do |k|
        row_values << row[k]
      end
      @values << row_values 
    end
    return { table:@table,header:@header,values:@values}
  end

  def self.get_ofx() #(filepath)

    statement = {}
    ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
    stmnt_from = ofx.index("<DTSTART>")
    stmnt_to = ofx.index("<DTEND>")
    balance = ofx.index("<BALAMT>")
    # ebal = get_eol(balance)
    tran_start = ofx.index("<BANKTRANLIST>")
    tran_end = ofx.index("</BANKTRANLIST>") -13

    puts "Start #{tran_start} END #{tran_end} STUFF #{ofx[tran_start..tran_end]}"
    tlist = ofx[tran_start..tran_end]
    lines = tlist.split(/[\r\n]+/)
    # linesbad = tlist.split # screws up without specific line ending
    transactions = []
    transactions << lines.each{|l| l.strip!}

    puts "TRANs #{transactions[0]}"
    # transactions.each do |t|
    #   puts t.size
    #   t = t[1..-1]
    #   puts "MOD #{t.size} #{t}"
    # end
    thing = []
    transactions[0].each do |t|
     nt = t[1..-1]
     k,v = nt.split('>')
     v = '' if v.nil?
     k = k.downcase
     nkv = k+':'+v
     thing << nkv
    end
    puts thing

    transactions[0]
    # need to fix so only one transactions
  end


  # def self.get_ofx() #(filepath)
  #   ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
  #   tran_start = ofx.index("<BANKTRANLIST>")
  #   tran_end = ofx.index("</BANKTRANLIST>") + 16
  #   puts "Start #{tran_start} END #{tran_end}"
  #   puts "txt start #{ofx[tran_start..(tran_start + 40)]}"
  #   puts "txt end #{ofx[(tran_end - 40)..(tran_end + 40)]}"
  #   ofx[tran_start..tran_end]

  # end

  def self.csv_to_hash(filepath)
    # A one line csv file to a hash removing BOM
    ahash = CSV.read(filepath, headers: true, header_converters: ->(h) { h.strip },encoding: "bom|utf-8").map(&:to_h)
    return ahash
  end

  def self.csv_text_to_hash(text)
    # A one line csv text to a hash removing BOM
    ahash = CSV.parse(text, headers: true, header_converters: ->(h) { h.strip },encoding: "utf-8").map(&:to_h)
    return ahash
  end

 
  def self.set_date(date)
    return date if date.class == Date
    return Date.today if date.blank?
    Date.parse(date) rescue Date.today
  end

  def self.from_to_as_range(from,to)
    from = Ledger.set_date(from)
    to = Ledger.set_date(to)
    from..to
  end

  def self.donations(range)
    family = [32,28,29,30,25]
    donation_entries = ledger_entries(family,range)
    bal = @balance ||= 0
    lines = [{id: nil,date: nil,numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    donation_entries.each do |t|
      date = t.post_date
      t.splits.each do |s|
        if family.include?(s.account_id)
          line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"",acct:nil,
            checking:{db:0,cr:0},details:[],r:nil,balance:0,split_cnt:0}
          line[:split_cnt] += 1
          line[:desc] = "#{t.description} - #{s.memo}"
          details = s.details
          line[:acct] = details[:name]
          line[:r] = details[:r]
          line[:checking][:db] += details[:db]
          line[:checking][:cr] += details[:cr]
          bal += details[:cr] 
          line[:balance] = bal
          line[:r] = details[:r]
          lines << line
        end
      end
    end
    lines
  end

  def self.dates_in_same_month(date1,date2)
    date1.month == date2.month && date1.year == date2.year
  end

  def self.to_amount(str)
    # string represention on money may have $ , or . characters
    # $1,999.23, 1,999.23, 1,999.237, 1999.2 1999

    dollars,cents = str.split('.')
    dollars = dollars.gsub(/\D/,'')
    return dollars.to_i if cents.blank? # $1,999  no cents but maybe $ or ,
    cents += '0' if cents.size == 1 # seen ofx have thing like 212.2 for 20 cents
    if cents.size > 2
      #integer round to 2 places
      cents = (cents.to_i + 5).to_s[0..1]
    end
    amt = (dollars+cents).to_i
  end


  def self.to_fixed(int)
    return '' if int.nil? || int.zero?
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
  end

  def self.statement_range(date)
    date = Ledger.set_date(date)
    bom = date.beginning_of_month
    eom = date.end_of_month
    bos = bom.on_weekend? || bom.wday == 1 ? bom.prev_weekday + 1.day : bom
    eos = eom.on_weekend? ? eom.prev_weekday  : eom
    bos..eos
  end

  def self.ledger_entries(family,range)
    Entry.where_assoc_exists(:splits,{ account_id: family})
      .where(post_date: range)
      .includes(:splits)
      .order(:post_date, :numb).distinct
  end

  def self.last_entry_date(family)
    Entry.where_assoc_exists(:splits,{ account_id: family})
    .includes(:splits)
    .order(:post_date).last.post_date
  end

  def self.entries_ledger(entries)
    # this is only for seach ledgers, not account ledgers
    bal = @balance ||= 0
    # kjdfjd = kljdfldj
    lines = [{id: nil,date: nil,numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    entries.each do |t|
      date = t.post_date
      line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"#{t.description}",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:0,split_cnt:0}
      # p "EEEEEE #{t.splits.count}"
      t.splits.each do |s|
        line[:split_cnt] += 1
        details = s.details
        line[:checking][:db] += details[:db]
        line[:checking][:cr] += details[:cr]
        bal += details[:cr] 
        line[:balance] = bal
        line[:r] = details[:r]
        line[:details] << details
      end
      lines << line
    end
    lines

  end

end
