class Book < ApplicationRecord
  acts_as_tenant(:client) ### for acts_as-tenant

  has_many :accounts, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :bank_statements, dependent: :destroy
  has_many :bank_transactions, dependent: :destroy
  has_many :audits, dependent: :destroy


  # has_many :bank_statements, dependent: :destroy
  # has_many :bank_transactions, dependent: :destroy

  serialize :settings, coder: JSON

  def root_acct
    self.accounts.find_by(code:'ROOT',level:0)
  end

  def checking_acct
    self.accounts.find_by(code:'CHECKING').id
  end
  
  def checking_ids
    self.accounts.find_by(code:'CHECKING').children.pluck(:id)
  end

  def checking_paths
    self.accounts.find_by(code:'CHECKING').children.pluck(:id,:name)
  end

  def checking_unrconciled_splits
    Split.where(account_id:self.checking_ids).where.not(reconcile_state:['y','v'])
  end
  
  def checking_cleared_splits
    Split.where(account_id:self.checking_ids).where(reconcile_state:'c')
  end

  def checking_unrconciled_find_amount(amount)
    self.checking_unrconciled_splits.where(amount:amount)
  end

  def acct_tree_ids
    unless self.settings.blank?
      self.settings['acct_transfers'].keys 
    end
  end

  def rebuild_book_setting
    # if any account is changed this rebuild the book setting
    # first set any acct level changes
    self.set_acct_levels
    # now rebuild the book settings
    self.settings = {}
    self.settings = {msg:"#{Time.now}: got message to REBUILD BOOK SETTINGS"}
    self.set_placeholders
    self.set_leafs
    self.set_acct_transfers
    self.save
  end

  def set_acct_levels
    accounts = self.build_tree
    accounts.each do |hash_acct|
      curr_acct = Account.find(hash_acct.id)
      if curr_acct.level != hash_acct.level 
        puts "LEVEL Changed #{curr_acct.level} == #{hash_acct.level} "
        curr_acct.update(level: hash_acct.level)
      end
    end
  end

  def set_placeholders
    # placeholders have children and can't be used in ledgers
    self.settings["acct_placeholders"] = self.accounts.where(placeholder:true).pluck(:id)
  end

  def set_leafs
    # leafs don't have children and can be used in ledgers
    self.settings["acct_leafs"] = self.accounts.where(placeholder:false).pluck(:id)
  end

  def set_acct_transfers
    # for ledger select options
    transfers = {}
    self.accounts.where(placeholder:false).each do |a|
      acct_name = a.long_account_name(true)
      transfers[a.id] = acct_name
    end
    self.settings["acct_transfers"] =  transfers
  end

  def acct_sel_opt
    unless self.settings.blank?
      self.settings['acct_transfers'].map{|k,v| [v,k]}.prepend(['',0]).sort
    end
  end

  def acct_placeholders_opt
    # only used in reports so not in settings
    # had error if placeholder has no children
    # fixed with unless statement but empty placeholders
    # should be deleted
    unless self.settings.blank?
      opt = {}
      accts = Account.find(self.settings["acct_placeholders"])
      accts.each do |a|
        lan = a.long_account_name
        unless lan.nil?
          opt[lan] = a.id
        end
      end
      opt
    end
  end

  def rev_acct_sel_opt
    unless self.settings.blank?
      self.settings['acct_transfers'].map{|k,v|
      v = v.split(':').reverse.join(':')
      [v,k]}.prepend(['',0]).sort
    end
  end

  def assets_acct
    self.accounts.find_by(code:['ASSET','ASSETS'],parent_id:self.root_acct)
  end

  def liabilities_acct
    self.accounts.find_by(code:'LIABILITY',parent_id:self.root_acct)
  end

  def equity_acct
    self.accounts.find_by(code:'EQUITY',parent_id:self.root_acct)
  end

  def income_acct
    self.accounts.find_by(code:'INCOME',parent_id:self.root_acct)
  end

  def expenses_acct
    self.accounts.find_by(code:'EXPENSE',parent_id:self.root_acct)
  end

  def checking_acct
    self.accounts.find_by(code:'CHECKING')
  end

  def savings_acct
    self.accounts.find_by(code:['SAVING','SAVINGS'])
  end

  def cash_acct
    self.accounts.find_by(code:'CASH')
  end

  def investments_acct
    self.accounts.find_by(code:'INVESTMENTS')
  end

  def current_assets
    self.accounts.find_by(code:'CURRENT')
  end


  # def acct_sel_opt_rev
  #   unless self.settings.blank?
  #     self.settings['acct_transfers'].map{|k,v| [k,v]}.prepend(['',0]).sort
  #   end
  # end


  def build_tree
    # gets all account in binary tree order start with the root account
    # used to get index of all accounts
    new_tree = []
    tree_root = self.root_acct
    tree_root.walk_tree(0,new_tree)
    new_tree
  end

  def build_acct_tree(acct)
    # used to get index of a branch defined by acct
    new_tree = []
    tree_root = acct
    tree_root.walk_tree(acct.level,new_tree)
    new_tree
  end

  def last_numbers(ago=6)
    # I think this is junk that is no longer used or needed
    # probably used for check number or some object sequence
    from = Date.today.beginning_of_month - ago.months
    nums = self.entries.where(Entry.arel_table[:post_date].gteq(from)).pluck(:numb).uniq.sort.reverse
    obj = {numb: 0} # for numb only
    nums.each do |n|
      if n.blank? 
        next #  blank or nil
      end
      key = n.gsub(/\d+/,'')
      val = n.gsub(/\D+/,'')
      next if key+val != n # only deal with key/numb not numb/key
      is_blk  = val == '' # key only
      num_only = val == n
      if !is_blk
        val = val.to_i
        is_num = true
      else
        is_num = false
      end
      if num_only
        obj[:numb] = val if ((val > obj[:numb]) && (val < 9000))
        next
      end
      key = key.to_sym 
      unless obj.has_key?(key)
        obj[key] = val 
        next
      end
      if is_num
        obj[key] = val if val > obj[key]
        next
      else
        obj[key] = val 
      end
    end
    obj
  end

  def auto_search(params)
    desc = params[:input]
    if params[:contains].present? && params[:contains] == 'true'
      entry_ids = self.entries.where(Entry.arel_table[:description].matches("%#{desc}%"))
      .order(Entry.arel_table[:id]).reverse_order.pluck(:description,:id)
    else
      entry_ids = self.entries.where(Entry.arel_table[:description].matches("#{desc}%"))
      .order(Entry.arel_table[:id]).reverse_order.pluck(:description,:id)
    end
    filter = entry_ids.uniq{|itm| itm.first}.to_h
  end

  def contains_any_word_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_any(words)).includes(:splits).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_all_words_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_all(words)).includes(:splits).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_match_query(match,all=nil)
    query = self.entries.where(Entry.arel_table[:description].matches("%#{match}%")).includes(:splits).order(:post_date).reverse_order
    return query if all.present? && all == "1"
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_number_query(match,all=nil)
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(Entry.arel_table[:numb].matches("#{match}%")).order(:numb).reverse_order
    # puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_amount_query(match,all=nil)
    bacct_ids = self.acct_tree_ids #- self.acct_placeholders
    eids = Split.where(account_id:bacct_ids).where(amount:match.to_i).pluck(:entry_id).uniq
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(id:eids).order(:post_date).reverse_order
    # puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def clone_accts_to_json
    #NOT USED
    # create a json clone of this book accounts
    accts = self.accounts.find(self.acct_tree_ids)
    tree_ids = accts.pluck(:id)
    new_tree_ids = {}
    #  create a hash with old id pointing to new id (starting a 1)
    tree_ids.each_with_index{|id,i| new_tree_ids[id]=i+1}
    # do as_json to filter accounts
    jaccts = accts.as_json(except:[:book_id, :contra,:client_id,:created_at,:updated_at,:code,:transfer,:leafs])
    jaccts.each do |ja|
      ja['id'] = new_tree_ids[ja['id']]
      ja['parent_id'] = new_tree_ids[ja['parent_id']] unless ja['parent_id'].nil?
    end
    jaccts.to_json
  end


  # just in case we want to re-import accounts 
  # def import_accounts
  #   json = File.read("/Users/salex/work/rails8/mybooks/app/models/concerns/accounts.json")
  #   accts = JSON.parse(json)
  #   accts.each do |a|
  #     na = Account.new(a)
  #     na.save
  #   end
  # end

end
