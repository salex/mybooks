class Entry < ApplicationRecord
  belongs_to :book
  acts_as_tenant(:client)

  attribute :amount, :integer
  attribute :reconciled
  has_many :splits, -> {order(:account_id)},dependent: :destroy, inverse_of: :entry

  accepts_nested_attributes_for :splits, 
    :reject_if =>  proc { |att| att[:amount].to_i.zero? && att[:account_id].to_i.zero?},
    allow_destroy: true


  def valid_params?(params_hash)
    split_sum = 0
    params_hash[:splits_attributes].each{|k,s| split_sum += s[:amount].to_i if s[:_destroy].to_i.zero?}
    unless split_sum.zero?
      errors.add(:amount, "Unbalanced: debits, credits must balance")
      return false
    else
      return true
    end
  end

  def bank_transaction
    bt = Current.book.bank_transactions.find_by(fit_id:self.fit_id)
    if bt.entry_id != self.id 
      bt.update(entry_id:self.id)
    end
    bt
  end

  def set_attributes
    self.amount = 0
    self.splits.each do |s|
      self.amount += s.credit 
    end
    # puts "AMT #{self.amount}"
  end

  def reconcile_state
    self.reconciled = self.splits.pluck(:reconcile_state).uniq
  end

  def reconciled?
    #if anything has 'y' consider reconciled
    reconcile_state.include?('y')
  end

  def cleared?
    #if anything has 'c' consider cleared
    reconcile_state.include?('c')
  end

  def has_fit_id?
    fit_id.present?
  end
  
  def duplicate
    new_entry = self.dup
    new_entry.numb = nil
    new_entry.fit_id = nil
    new_entry.post_date = Date.today
    self.splits.each do |s|
      s_attr = s.attributes.symbolize_keys.except(:id,:created_at,:updated_at,:reconcile_date,:reconcile_state)
      new_entry.splits.build(s_attr)
    end
    new_entry.splits.build()
    new_entry   
  end

  def duplicate_with_bank(bank)
    new_entry = self.dup
    new_entry.numb = bank.ck_numb unless bank.ck_numb.to_i > 9000
    new_entry.post_date = bank.post_date.to_date
    new_entry.fit_id = bank.fit_id
    amount = bank.amount
    # need to replace debit, credit and amount to bank stuff
    # since only two splits allowed, use amount from bank to set debits and credits
    # flip amount after first split
    # there are only two splits allowed for dup
    self.splits.each do |s|
      s_attr = s.attributes.symbolize_keys.except(:id,:created_at,:updated_at,:reconcile_date,:reconcile_state)
      s.amount = amount
      set_debit_credit(s)
      s_attr[:debit] = s.debit
      s_attr[:credit] = s.credit
      s_attr[:amount] = s.amount
      # amount comes from trans
      s_attr[:reconcile_state] = 'c'
      new_entry.splits.build(s_attr)
      # toggle abmount from first split
      amount = amount * -1
    end
    new_entry.splits.build()
    new_entry   
  end

  def link_ofx_transaction(fit_id)
    checking_ids = Current.book.checking_ids
    s = self.splits.where(account_id:checking_ids, reconcile_state:['n','c'])
    s.update_all(reconcile_state:'c') if s.present?
    self.update(fit_id:fit_id)
    bt = Current.book.bank_transactions.find_by(fit_id:fit_id)
    bt.entry_id = self.id 
    bt.save
  end

  def set_debit_credit(s)
    if s.amount.blank?
      s.amount = 0
    end
    if s.amount < 0
      s.credit = s.amount * -1
      s.debit = 0
    else
      s.credit = 0
      s.debit = s.amount
    end
  end

end
