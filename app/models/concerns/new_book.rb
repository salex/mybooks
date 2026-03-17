class NewBook
  attr_accessor :accts,:book

  def initialize
    file_path = "#{Rails.root}/app/models/concerns/new_book.txt"

    @accts = File.read(file_path)
    parse
  end

  def parse
    @book = [] 
    accts = @accts.split("\n")
    accts.each.with_index do |acct,idx|
      node = {}
      key,acct_name = acct.split
      node[:id] = idx
      #id will be replaced with real id after create
      node[:key] = key
      code = ''
      if acct_name[0] == '!'
        code = acct_name[1..-1].upcase
        acct_name = acct_name[1..-1]
      end
      node[:acct_name] = acct_name
      split = key.split('.')
      node[:level] = split.size - 1
      node[:code] = code
      node[:parent] = split[0..(node[:level] - 1)].join('.')
      book << node
    end
  end

  def create
    # create root account first
    # set root_id root.id
    root = book[0]
    puts root
    book[1..-1].each do  |acct|
      puts acct[:acct_name]
    end
      # new_acct = Account.new(
      #   name:acct[:acct_name],
      #   level:acct[:level]
      #   code:acct[:code],
      #   )

  end

  def book_find_by(key,value)
    book.select { |h| h[key] == value }
  end

end
