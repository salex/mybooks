class Entries::FilterController < EntriesController
  def index
    render template:'entries/actions/filter'
  end

 end