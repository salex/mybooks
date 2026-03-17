class ApplicationController < ActionController::Base
  set_current_tenant_through_filter
  include Authentication
  # Only allow modern browsers supporting web images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :session_expiry

  def session_expiry

    if Current.session
      # if Current.user.is_super?
      #   # Allow access to all tenants
      #   ActsAsTenant.current_tenant = nil
      # end
      # # puts "CURRENT ATTRIBUTES #{Current.attributes}"
      # puts "Current user #{Current.user.attributes}"
      Current.book = Book.find(Current.user.default_book)

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
