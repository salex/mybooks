class Audit < ApplicationRecord
  acts_as_tenant(:client)
  belongs_to :book

  serialize :settings, coder: JSON

  attribute :summary

end

