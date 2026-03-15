class MyOfx
  # NOT USED OLD VERSION
  attr_accessor :account
  attr_accessor :transactions
  attr_accessor :node

  # def self.get_ofx() #(filepath)
  #   # ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
  #   # tran_start = ofx.index("<BANKTRANLIST>")
  #   # tran_end = ofx.index("</BANKTRANLIST>") + 16
  #   # puts "Start #{tran_start} END #{tran_end}"
  #   # # puts "txt start #{ofx[tran_start..(tran_start + 40)]}"
  #   # # puts "txt end #{ofx[(tran_end - 40)..(tran_end + 40)]}"
  #   # trans = ofx[(tran_start)..(tran_end)]
  #   # splits = trans.split(/\r\n/)
  #   # strans = []

  #   # splits.each do |t|
  #   #   strans << t.strip!

  #   # end
  #   # strans
  #   # puts "STRANS #{trans.strip!}"
  #   # arr = []
  #   # trans.each do |t|
  #   #   arr << t.strip!
  #   # end
  #   # arr

  #   # get other attrubytes

  #   # dtstart = t.find{|x| x.include?("<DTSTART>")}
  #   # => "<DTSTART>20260201000000.000[-6:CST]"
  #   # dtend = t.find{|x| x.include?("<DTEND>")}
  #   # => "<DTEND>20260228235959.000[-6:CST]"
  #   # balance = ofx.index("<BALAMT>")


  #   statement = {}
  #   ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
  #   stmnt_from = ofx.index("<DTSTART>")
  #   stmnt_to = ofx.index("<DTEND>")
  #   balance = ofx.index("<BALAMT>")
  #   # ebal = get_eol(balance)
  #   tran_start = ofx.index("<BANKTRANLIST>")
  #   tran_end = ofx.index("</BANKTRANLIST>") + 16
  #   puts "Start #{tran_start} END #{tran_end}"
  #   tlist = ofx[tran_start..tran_end]
  #   lines = tlist.split(/[\r\n]+/)
  #   # linesbad = tlist.split # screws up without specific line ending
  #   transactions = []
  #   transactions << lines.each{|l| l.strip!}
  #   # transactions.each do |t|
  #   #   puts t.size
  #   #   t = t[1..-1]
  #   #   puts "MOD #{t.size} #{t}"
  #   # end
  #   thing = []
  #   transactions[0].each do |t|
  #     nt = t[1..-1]
  #     k,v = nt.split('>')
  #     v = '' if v.nil?
  #     k = k.downcase
  #     nkv = k+':'+v
  #     # thing << nt.split('>').join(':')
  #     thing << nkv
  #   end

  #   transactions[0]
  #   # need to fix so only one transactions
  # end

  # def self.make_hash(trans)
  #   thing = []
  #   trans.each |t|
  #     nt = t[1..-1]
  #     thing << nt.split('>')
  #   end
  #   puts thing
  # end

  def initialize(ofx)
    @ofx = ofx 
    @xml = ofx_to_xml
    return @xml
    @node = Nokogiri::HTML(@xml)
    build_transactions
    build_account(node)
  end

  def ofx_to_xml
    xml = ""
    ofx_arr = @ofx.split("\r\n")
    ofx_arr.each do |elm|
      elm_arr = elm.split(">")
      if elm_arr.size != 2
        xml += (elm + "\r\n")
        next 
      end
      elm_arr[0] += '>' # add back > that split removed
      otag = elm_arr[0].strip
      ctag = otag[0]+'/' + otag[1..-1] # build closing tag
      line = elm_arr[0]+elm_arr[1]+ctag
      xml += (line + "\r\n")
    end
    xml
  end

  # def build_transactions
  #   @transactions = []
  #   @node.xpath('//banktranlist//stmttrn').collect do |element|
  #     @transactions << self.build_transaction(element)
  #   end
  # end

  def build_transaction(element)
    trans = {
       amount: build_amount(element),
       amount_in_pennies: ((build_amount(element) * 100).round(2)).to_i,
       fit_id: (element.search('fitid').text),
       memo: (element.search('memo').text),
       name: (element.search('name').text),
       payee: element.search('payee').text,
       check_number: (element.search('checknum').text),
       ref_number: (element.search('refnum').text),
       posted_at: build_date(element.search('dtposted').text),
       # occurred_at: occurred_at,
       # type: build_type(element),
       sic: (element.search('sic').text)
     }
     return trans
  end

  def build_amount(element)
    element.search('trnamt').text.to_f
  end

  def build_date(date)
    # for rails it's only to_time
    date.to_time
  end

  def build_account(node)
    account_types = {
      'CHECKING' => :checking,
      'SAVINGS' => :savings,
      'CREDITLINE' => :creditline,
      'MONEYMRKT' => :moneymrkt
    }.freeze

    @account = {
      bank_id: node.search('bankacctfrom > bankid').inner_text,
      id: node.search('bankacctfrom > acctid, ccacctfrom > acctid').inner_text,
      type: account_types[node.search('bankacctfrom > accttype').inner_text.to_s.upcase],
      balance: build_balance(node),
      available_balance: build_available_balance(node),
      currency: node.search('stmtrs > curdef, ccstmtrs > curdef').inner_text,
      transactions: @transactions
    }
  end

  def build_balance(node)
    amount = to_decimal(node.search('ledgerbal > balamt').inner_text)
    posted_at = begin
      build_date(node.search('ledgerbal > dtasof').inner_text)
    rescue StandardError
      nil
    end
    balance = {
     amount: amount,
     amount_in_pennies: ((amount * 100).round(2)).to_i,
     posted_at: posted_at
    }
  end

  def build_available_balance(node)
    if node.search('availbal').size > 0
      amount = to_decimal(node.search('availbal > balamt').inner_text)
      available_balance = {
        amount: amount,
        amount_in_pennies: ((amount * 100).round(2)).to_i,
        posted_at: build_date(node.search('availbal > dtasof').inner_text)
      }
    end
  end

  def to_decimal(amount)
    BigDecimal(amount.to_s.gsub(',', '.'))
  rescue ArgumentError
    BigDecimal('0.0')
  end

end
