class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Get counts and lists of updates that are pending
  before_filter do
    @outstanding_regular = PackageUpdate.by_package(PackageUpdate.not_applied.not_security)
    @outstanding_security = PackageUpdate.by_package(PackageUpdate.not_applied.security)
  end

  before_filter do
    @breadcrumbs = BreadcrumbList.new
  end

  private

  def flash_success(title, content)
    flash["successes"] ||= []
    flash["successes"] << {"title" => title, "content" => content}
  end

  def flash_error(title, content)
    flash["errors"] ||= []
    flash["errors"] << {"title" => title, "content" => content}
  end

  def require_login
    if session[:current_user_id].blank?
      if cookies[:remember_me_token] && user = User.find_by(token: cookies[:remember_me_token])
        session[:current_user_id] = user.id
        @@current_user = user
      else
        session[:post_login_url] = request.url
        redirect_to login_path
      end
    end

    if session[:current_user_id] && !@current_user
      begin
        @current_user = User.find(session[:current_user_id])
      rescue ActiveRecord::RecordNotFound
        session.delete(:current_user_id)
        session[:post_login_url] = request.url
        redirect_to login_path
      end
    end
  end
end
