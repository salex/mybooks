class HomeController < ApplicationController
  allow_unauthenticated_access only: [:index]
  before_action :resume_session, except: [:index]


  def index
      puts "HAS SESSION #{Current.session.present?}"
      render template: 'home/index'
  end
  def show
      render template: 'home/dashboard'
  end
  def import
    render template: 'home/import'
  end

end
