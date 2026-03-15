class Split < ApplicationRecord
  belongs_to :account
  belongs_to :entry
  acts_as_tenant(:client)
  # acts_as_tenant(:entry)

  attribute :debit, :integer
  attribute :credit, :integer
  attribute :transfer, :string

  validates_associated :account
  validates_associated :entry

  after_find do |split|
    set_debit_credit(split) if Current.book.present?
  end

  def details
    return {name:self.transfer,cr:self.credit,db:self.debit,
      amount:self.amount, action: self.action, memo:self.memo, 
      r:self.reconcile_state, acct_id:self.account_id}
   end

   def self.fix_reconcile_date
     recent = Split.where("reconcile_date > ?", "2024-01-01")
     recent.each do |s|
       if s.reconcile_date.day == 1
         s.reconcile_date -= 1
         s.save
       end
     end
   end
   
  private

  def set_debit_credit(s)
    self.transfer =  Current.book.settings['acct_transfers'][s.account_id.to_s]
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
