module BooksHelper
  # this need looked into
  # think only for recent accts and overkill
  def set_book_session(book)
    checking_account = book.checking_acct
    session[:recent]= {}
    session[:book_id] = book.id
    if checking_account.present?
      leafs = checking_account.leaf.sort
      session[:recent][checking_account.id.to_s] = checking_account.name
      sub_accts = Account.find(leafs)
      sub_accts.each do |l|
        session[:recent][l.id.to_s] = l.name
      end
    end
  end
end