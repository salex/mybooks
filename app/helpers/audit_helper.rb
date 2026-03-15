module AuditHelper
  def to_struct(ahash)
    struct = ahash.to_struct
    struct.members.each do |m|
      struct[m] = to_struct(struct[m]) if struct[m].is_a? Hash
    end
    struct 
  end

  def get_audit(date=nil)
    # 
    if Current.book.blank?
      Current.book = Book.find 1
    end

    # GET BASE STUFF
    date_from = @audit.date_from
    date_to = date_from.end_of_quarter
    checking_id = Current.book.checking_acct.id
    savings_id = Current.book.savings_acct.id
    invest_id = Current.book.investments_acct.id
    cash_id = Current.book.cash_acct.id
    # @audit is set in audits/contoller print action and duped to audit
    audit = @audit
    settings = to_struct(YAML.load(audit.settings))
    # GET ACCOUNTS/FUNDS
    savings = Account.find(savings_id).family_summary(date_from,date_to)[savings_id]
    checking = {}
    # the gets the funds from checking account
    Current.book.checking_ids.each do |aid|
      acct = Account.find(aid)
      checking[acct.name.downcase.to_sym] = acct.family_summary(date_from,date_to)[aid]
    end
    cash = Account.find(cash_id).family_summary(date_from,date_to)[cash_id]
    investments = Account.find(invest_id).family_summary(date_from,date_to)[invest_id]
    # GET OTHER ATTRIBUTES
    range = audit.date_from..audit.date_from.end_of_quarter
    assets = get_assets(date_from)
    # a hash is returned that gets converted to a struct
    return {checking:checking,savings:savings,investments:investments,cash:cash,assets:assets,config:settings, range:range}
  end

  def get_assets(date_in_quarter)
    boq = date_in_quarter.beginning_of_quarter
    eoq = boq.end_of_quarter
    cash = checking = savings = total = investments = nil
    range = boq..eoq
    summary = Book.find(1).current_assets.family_summary(range.first,range.last)

    summary.each do |k,v|
      # puts "K #{k} VAL #{v}"
      cash = v if v[:name] == 'Cash'
      checking =  v if v[:name] == 'Checking'
      savings =  v if v[:name] == 'Savings'
      investments = v if v[:name] == 'Investments'
      total = v if v[:name] == 'Current'
    end
    # bxxxx short for balances[name]
    bsave = savings[:ending]
    bcash = cash[:ending]
    btotal = total[:ending]
    bcheck = checking[:ending]
    binvest = investments[:ending]
    funds = checking[:children]
    # puts "CHECKING #{checking}"

    assets = {cash:cash,
      checking:checking,
      savings:savings,
      total:total,
      bsave:bsave,
      bcash:bcash,
      btotal:btotal,
      bcheck:bcheck,
      binvest:binvest,
      funds:funds
    }
    # puts "ASSETS #{assets.keys}"
    return to_struct(assets)
  end


end
