=begin
  this is a debugging controller
  just to see the split and the entry in a single view
=end

class SplitsController < ApplicationController

  def show
    split = Split.find_by(id:params[:id])
    @entry = split.entry 
    render template:'entries/show'
  end
end
