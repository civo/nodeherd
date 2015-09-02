class SessionsController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def new
    if request.post? && user = User.login(params[:email], params[:password])
      Rails.logger.debug("Logged in!")
      session[:current_user_id] = user.id
      redirect_to (session[:post_login_url] || "/")
      session.delete(:post_login_url)
      if params[:remember_me]
        cookies.permanent[:remember_me_token] = user.token
      end
    elsif request.post?
      flash[:errors] = [{title: "Failed to login", content: "Sorry, you must have used incorrect login information, please try again."}]
      redirect_to login_path
    end
  end

  def destroy
    session.delete(:current_user_id)
    session.delete(:post_login_url)
    cookies.delete(:remember_me_token)
    redirect_to login_path
  end
end
