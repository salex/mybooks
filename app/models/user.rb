class User < ApplicationRecord
  acts_as_tenant(:client) ### for acts_as-tenant
  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  alias_attribute :role, :roles

  attribute :permits

  after_initialize :set_attributes

  def set_attributes
    self.permits = Can.can(self.role) unless self.role.blank?
  end

  def can?(action, model)
    return false if self.role.nil? || self.permits.nil?
    action = action.to_s.downcase
    model = model.to_s.downcase
    permit = permits[model.to_sym]
    return false if permit.nil?

    if [ "create", "new" ].include?(action)
      permit[0] == "1"
    elsif [ "index", "show", "read" ].include?(action)
      permit[1] == "1"
    elsif [ "edit", "update" ].include?(action)
      permit[2] == "1"
    elsif [ "delete", "destroy" ].include?(action)
      permit[3] == "1"
    else
      false
    end
  end

  def owner?(model)
    model.has_attribute?(:user_id) && self.id == model.user_id
  end

  def is_manager?
    self.role == "super" || self.role == "manager"
  end

  def is_admin?
    self.role == "super" || self.role == "manager"
  end

  # def is_admin?
  #   self.role == "super" || self.role == "manager"
  # end


  def is_super?
    self.role == "super"
  end
end
