class Can
  CRUD = {
    super: {
      client: "1111",
      book: "1111",
      user: "1111",
      account: "1111",
      entry: "1111",
      split: "1111",
      bank_statement: "1111",
      comment: "1111"
    },
    manager: {
      client: "0110",
      book: "1111",
      user: "1111",
      account: "1111",
      entry: "1111",
      split: "1111",
      bank_statement: "1111",
      comment: "1111"
    },
    admin: {
      client: "1111",
      book: "1111",
      user: "1111",
      account: "1111",
      entry: "1111",
      split: "1111",
      bank_statement: "1111",
      comment: "1111"
    },
    guest: {
      client: "1111",
      book: "1111",
      user: "1111",
      account: "1111",
      entry: "1111",
      split: "1111",
      bank_statement: "1111",
      comment: "1111"
    }
  }

  def self.can(role)
    # called from User model - returns user roles
    cans = CRUD[role.downcase.to_sym]
  end

  # below is just testing methods
  def self.crud
    CRUD
  end

  def self.roles
      CRUD.keys.map { |o| o = o.to_s }
    end

  def self.models
    CRUD[:super].keys.map { |o| o = o.to_s }
  end

  # def self.to_yaml
  #   return CRUD.to_yaml
  # end
end
