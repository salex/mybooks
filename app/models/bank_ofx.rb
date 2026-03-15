class BankOfx < BankStatement

  def get_transactions
    ofx = parse_ofx
    build_transactions(ofx)
  end

  def parse_ofx
    ofx = File.read("/Users/salex/downloads/Transactions-13.qbo")
    results = Hash.new
    stmnt_from = ofx.index("<DTSTART>") #.slice(/.*?(?=\r|\n)/).strip
    getf = ofx[stmnt_from..(stmnt_from + 50)]
    stmnt_from = getf.slice(/.*?(?=\r|\n)/).strip

    stmnt_to = ofx.index("<DTEND>")
    getf = ofx[stmnt_to..(stmnt_to + 50)]
    stmnt_to = getf.slice(/.*?(?=\r|\n)/).strip

    balance = ofx.index("<BALAMT>")
    getf = ofx[balance..(balance + 20)]
    balance = getf.slice(/.*?(?=\r|\n)/).strip

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
