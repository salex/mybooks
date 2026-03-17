class Account < ApplicationRecord
  acts_as_tenant(:client)
  belongs_to :book

  has_many :splits, dependent: :destroy
  has_many :entries, through: :splits, dependent: :destroy
  belongs_to :parent, foreign_key: :parent_id, class_name: 'Account', optional: true
  attribute :leafs
  attribute :transfer

  after_save :rebuild_book_setting

  def rebuild_book_setting
    # puts "WOULD REBUILD BOOK SETTINGS"
    self.book.rebuild_book_setting
  end

  def children
    self.book.accounts.where(parent_id:self.id).order(:name)
  end

  def has_children?
    !children.blank?
  end

  def leaf(leaf_array=[])
    if self.leafs.present?
      # p "GETTING LEAFS"
      return self.leafs 
    else
      # p "SETTING LEAFS"
      self.children.each do |c|
        unless c.has_children?
          leaf_array << c.id
        end
        c.leaf(leaf_array)
      end
      self.leafs = leaf_array
    end
    return self.leafs
  end

  def last_entry_date
    e = Entry.where_assoc_exists(:splits,{ account_id: family_tree_ids})
    .includes(:splits)
    .order(:post_date).last
    if e.present?
      e.post_date
    else
      Date.today.beginning_of_year
    end
  end

  def destroyable?
    self.children.blank? && self.entries.blank?
  end



  def family_tree_ids
    # Only used in self.last_entry_date to get the all entries for the family and me
    # if self is a leaf (no childre) it will be an array [:id]
    # if self has children it will be array [:id,e0.id, e1.id, etc]
    self.family.pluck(:id) << self.id
  end



  def balance
    bal = self.splits.sum(:amount)  * self.flipper
  end

  def family
    kids = children
    kids.each do |child|
      kids += child.family
    end
    kids
  end

  def family_balance
    bal = balance
    bal += family_child_balance
  end

  def family_child_balance
    bal = 0
    self.children.each do |child|
      bal += child.balance
      bal += child.family_child_balance
    end
    bal
  end

  def long_account_name(reverse=false)
    account_name = self.name
    the_parent = self.parent 
    while the_parent.present? && the_parent.account_type != 'ROOT'
      if reverse
        account_name = account_name + ":" + the_parent.name
      else
        account_name = the_parent.name + ":" + account_name
      end
      the_parent = the_parent.parent
    end
    # for data_lookup don't think used
    # account_name = "#{account_name}[#{self.id}]" if reverse
    # if account_name.include?('Archived')
    #   return nil 
    # else
    #   return account_name
    # end
    account_name
  end

  def walk_tree(level,new_tree)
    self.level = level
    self.transfer = self.long_account_name
    new_tree << self
    level += 1
    self.children.each do |child|
      child.walk_tree(level,new_tree)
    end
    level -= 1
    new_tree
  end

  def flipper
    # defines normal credit balance
    #TODO  implement contra * -1 if self.contra- nah!
    pm = %{INCOME EQUITY LIABILITY}.include?(self.account_type)  ? -1 : 1
  end

  def balance
    bal = self.splits.sum(:amount)  * self.flipper
  end

  def balance_on(date)
    date = Ledger.set_date(date)
    self.splits.joins(:entry).where(Entry.arel_table[:post_date].lteq(date)).sum(:amount) * self.flipper
  end
  alias ending_balance balance_on

  def balance_before(date)
    date = Ledger.set_date(date)
    self.splits.joins(:entry).where(Entry.arel_table[:post_date].lt(date)).sum(:amount) * self.flipper
  end
  alias beginning_balance balance_before

  def family_balance
    bal = balance
    bal += family_child_balance
  end

  def family_child_balance
    bal = 0
    self.children.each do |child|
      bal += child.balance
      bal += child.family_child_balance
    end
    bal
  end

  def family_balance_on(date)
    date = Ledger.set_date(date)
    bal = balance_on(date)
    bal += family_child_balance_on(date)
  end

  def family_child_balance_on(date)
    date = Ledger.set_date(date)
    bal = 0
    self.children.each do |child|
      bal += child.balance_on(date)
      bal += child.family_child_balance_on(date)
    end
    bal
  end

  # Summaries and ledgers
  def branches(branch_array=[])
    self.children.each do |c|
      if c.has_children?
        branch_array << c.id
      end
      c.branches(branch_array)
    end
    branch_array
  end


  def family_summary(from,to)
    id = self.id
    root = {id => self.summary(from,to)}
    branches = Account.includes(:book).where(id:self.branches)
    branches.each do |b|
      root[b.id] = b.summary(from,to)
    end
    leaves = Account.includes(:book).where(id:self.leaf)
    leaves.each do |l|
      root[l.id] = l.summary(from,to)
      parent = root[l.id][:parent_id]
      while parent != id
        root[parent][:beginning] += root[l.id][:beginning]
        root[parent][:debits] += root[l.id][:debits]
        root[parent][:credits] += root[l.id][:credits]
        root[parent][:diff] += root[l.id][:diff]
        root[parent][:ending] += root[l.id][:ending]
        parent = root[parent][:parent_id] 
      end
      root[id][:beginning] += root[l.id][:beginning]
      root[id][:debits] += root[l.id][:debits]
      root[id][:credits] += root[l.id][:credits]
      root[id][:diff] += root[l.id][:diff]
      root[id][:ending] += root[l.id][:ending]
    end
    root
  end

  def summary(from,to)
    from = Ledger.set_date(from)
    to = Ledger.set_date(to)
    # another forever error on beginning balance
    # beginning = self.balance_on(from -1.day) * self.flipper
    beginning = self.beginning_balance(from) * self.flipper

    splits = self.splits.joins(:entry).where(entries: {post_date:[from..to]})
    debits = splits.where(splits.arel_table[:amount].gt(0)).sum(:amount) 
    diff = splits.sum(:amount) * self.flipper
    ending = beginning + diff
    credits = debits - diff  * self.flipper
    {beginning:beginning,
      debits:debits,
      credits:credits,
      diff:diff,
      ending:ending,
      children:self.children.pluck(:id),
      parent_id:self.parent_id,
      name:self.name,
      description:self.description,
      level:self.level}
  end

  def children_ledger(date=nil,to=nil)
    date = Ledger.set_date(date)
    if to.present? # assume date = from and to = to
      @bom = date
      @eom =  Ledger.set_date(to)
    else
      @bom = date.beginning_of_month
      @eom = date.end_of_month
    end
    @kid_ids = leaf
    acct_trans =Ledger.ledger_entries(@kid_ids,@bom..@eom)
    @balance = family_balance_on(@bom - 1.day)
    lines = build_ledger(acct_trans)
  end

  def account_ledger(date=nil,to=nil)
    date = Ledger.set_date(date)
    if to.present? # assume date = from and to = to
      @bom = date
      @eom =  Ledger.set_date(to)
    else
      @bom = date.beginning_of_month
      @eom = date.end_of_month
    end
    acct_trans =Ledger.ledger_entries(self.id,@bom..@eom)
    # been wrong for a long time. Below is what once starting_balance_on
    # if tranasction on 1st day, beginning was wrong
    # @balance = balance_on(@bom - 1.day) is replace with beginnng_balance alias
    @balance = beginning_balance(@bom)
    build_ledger(acct_trans)
  end

  def build_ledger(acct_trans)
    bal = @balance ||= 0
    kids  = @kid_ids ||= [self.id]
    debits = credits = diff = 0
    lines = [{id: nil,date: @bom.strftime("%m/%d/%Y"),numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    acct_trans.each do |t|
      date = t.post_date
      line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"#{t.description}",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:0}
      numb_splits = t.splits.length
      t.splits.each do |s|
        details = s.details
        if kids.include?(details[:acct_id]) 
          debits += details[:db]
          credits += details[:cr]
          diff +=  details[:amount] * self.flipper
          line[:checking][:db] += details[:db]
          line[:checking][:cr] += details[:cr]
          bal += details[:amount] * self.flipper
          line[:balance] = bal #
          line[:r] = details[:r]

        else
          line[:balance] = bal
          unless numb_splits > 2
            # this is a entry with only two splits
            line[:memo] = details[:name]
          else
            line[:memo] = "- Split Transaction -"
          end
        end
        line[:details] << details
      end
      lines << line
    end
    # p "possible endg db = #{debits} cr = #{credits} diff = #{diff}"
    summary = {id: nil,date: @eom.strftime("%m/%d/%Y"),numb:nil,desc:"Range Summary",
        checking:{db:debits,cr:credits},details:[], memo:nil,r:nil,balance:diff}
    lines << summary
  end

end
