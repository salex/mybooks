module Vfw
  class PostController < ApplicationController
    # before_action :require_book
    
    def index
    end

    def voucher
      @date = Ledger.set_date(params[:id])
      @from = @date.beginning_of_month
      level = params[:level] || 1
      @to = @date.end_of_month
      @account = Current.book.current_assets
      @summary = @account.family_summary(@from,@to)
      @report = Report.new.profit_loss({from:@from,to:@to,level: level})
    end

    def quarter
      @date = Ledger.set_date(params[:id])
      @from = @date.beginning_of_quarter
      level = params[:level] || 1
      @to = @date.end_of_quarter
      @account = Current.book.current_assets
      @summary = @account.family_summary(@from,@to)
      @report = Report.new.profit_loss({from:@from,to:@to,level: level})
    end

  end
end
