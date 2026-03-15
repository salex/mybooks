class Entries::FilteredController < ApplicationController

  def update
    if params[:commit] == "Search Split Amount"
      entries = Current.book.contains_amount_query(params[:words])
    elsif params[:commit] == "Search Entry Number"
      entries = Current.book.contains_number_query(params[:words])
    elsif params[:how].present? && params[:how] == 'any'
      entries = Current.book.contains_any_word_query(params[:words])
    elsif  params[:how].present? && params[:how] == 'all'
      entries = Current.book.contains_all_words_query(params[:words])
    else
      entries = Current.book.contains_match_query(params[:words], params[:show_all])
    end
    @lines = Ledger.entries_ledger(entries)
    render turbo_stream: turbo_stream.replace(
      'entries',
      partial: '/entries/actions/filtered')
 

  end
end