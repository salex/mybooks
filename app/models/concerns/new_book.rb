class NewBook
  attr_accessor :accts,:book, :tree

  def initialize
    # puts "Hello NewBook"
    file_path = "#{Rails.root}/app/models/concerns/new_book.txt"

    @accts = File.read(file_path)
    parse3
  end

  def parse3
    @book = [] 
    # stack = [[0,0]]
    accts = @accts.split("\n")
    accts.each.with_index do |acct,idx|
      node = {}
      key,acct_name = acct.split
      node[:id] = idx + 1
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


  def make_tree
    @tree = {}
    arr = @accts.split
    stack = []
    arr.each.with_index do |acct,idx|
      node = {}
      lev = acct.to_i
      acct = acct[1..-1] # remove level from acct
      if acct[0] == '!'
        code = acct[1..-1].upcase
        acct = acct[1..-1]
      end
      node[:acct] = acct
      node[:lev] = lev
      node[:code] = code
      node[:pid] = [idx]
      tree[idx] = node
    end

  end

  def parse
    @book = [] 
    stack = [[0,0]]
    arr = @accts.split
    # puts "initSTACK #{stack.last.inspect} xx #{stack.last[1]}"
    pid = 0

    arr.each.with_index do |acct,idx|
      code = ''
      id = idx
      lev = acct.to_i # get the level
      acct = acct[0..-1] # remove level from acct
      k = [id,lev] # build a key from id and kev
      # puts "STACK0 #{stack.last.inspect} xx #{stack.last[1]}"
      if lev > stack.last[1]
        pid = stack.last[0]
        stack.push(k)
        # puts "GREATER"
      elsif lev == stack.last[1]
        # pid = stack.last[0]
        # puts "EQUAL"
      else
        puts stack.inspect
        stack.pop
        puts stack.inspect
        pid = stack.last[0]
        # puts "LESS"
      end
      # puts "STACK1 #{stack.last[1].inspect}"
      if acct[0] == '!'
        code = acct[1..-1].upcase
        acct = acct[1..-1]
      end
      book << {id:id,account:acct,level:lev,code:code,pid:pid}
    end
    puts stack
  end

  def parse2
    @book = []
    stack = [[0,0]]
    arr = @accts.split
    # puts "initSTACK #{stack.last.inspect} xx #{stack.last[1]}"
    pid = 0

    arr.each.with_index do |acct,idx|
      code = ''
      id = idx
      lev = acct.to_i # get the level
      acct = acct[0..-1] # remove level from acct
      k = [id,lev] # build a key from id and kev
      # puts "STACK0 #{stack.last.inspect} xx #{stack.last[1]}"
      if lev > stack.last[1]
        pid = stack.last[0]
        stack.push(k)
        # puts "GREATER"
      elsif lev == stack.last[1]
        # pid = stack.last[0]
        # puts "EQUAL"
      else
        puts stack.inspect
        stack.pop
        puts stack.inspect
        pid = stack.last[0]
        # puts "LESS"
      end
      # puts "STACK1 #{stack.last[1].inspect}"
      if acct[0] == '!'
        code = acct[1..-1].upcase
        acct = acct[1..-1]
      end
      book << {id:id,account:acct,level:lev,code:code,pid:pid}
    end
    puts stack
  end

end