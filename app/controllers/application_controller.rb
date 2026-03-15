class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  include Authentication
  # Only allow modern browsers supporting web images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :session_expiry

  def session_expiry

    if Current.session

      # puts "CURRENT ATTRIBUTES #{Current.attributes}"
      # puts "Current user #{Current.user.attributes}"
      Current.book = Book.find(Current.user.default_book)
      # puts "CURRENT BOOL #{Current.book}"

      # unless session[:book_id].present?
      # helpers.set_book_session(Current.book)
      # end
      # session[:steve] = 'alex'
      Current.client = Current.book.client
      set_current_tenant(Current.client)### for acts_as-tenant
      key = "#{Current.session.id}_expires_at"
      if session[key].present? && session[key] < Time.now
        terminate_session
        reset_session
        redirect_to root_path, flash: {alert: "Your session has expired!"}
      else
        session[key] = Time.now + 90.minutes
      end
    end
    # puts " LEAVING SESSION EXPIRED"
  end

end
