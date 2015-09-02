class UsersController < ApplicationController
  before_filter :require_login

  def index
    @breadcrumbs.add(users_path, "Users", "users")
    @page_title = "Users"
    @page_subtitle = "Where everybody knows your name..."
    @users = User.all
  end

  def new
    @breadcrumbs.add(users_path, "Users", "users")
    @breadcrumbs.add(new_user_path, "New user", "users")
    @page_title = "New User"
    @page_subtitle = "Big brother needs all their details!"
    @user = User.new
    render :form
  end

  def create
    @breadcrumbs.add(users_path, "Users", "users")
    @breadcrumbs.add(new_user_path, "New user", "users")
    @page_title = "New User"
    @page_subtitle = "Big brother needs all their details!"
    @user = User.new(user_params)
    if @user.save
      flash_success("Welcome to the team", "The new user has been created, feel free to ask them to log in and change their password")
      redirect_to users_path
    else
      render :form
    end
  end

  def edit
    @user = User.find(params[:id])
    @breadcrumbs.add(users_path, "Users", "users")
    @breadcrumbs.add(new_user_path, "Editing #{@user.name}", "users")
    @page_title = @user.name
    @page_subtitle = "Got something wrong?"
    render :form
  end

  def update
    @user = User.find(params[:id])
    @breadcrumbs.add(users_path, "Users", "users")
    @breadcrumbs.add(new_user_path, "Editing #{@user.name}", "users")
    @page_title = @user.name
    @user.update(user_params)
    if @user.save
      flash_success("Fixed 'em up, sir!", "That user has been updated, good as new!")
      redirect_to users_path
    else
      render :form
    end
  end

  def destroy
    @user = User.find(params[:id])
    if User.count > 1
      @user.destroy
      flash_success("Bang!", "We've terminated that user with extreme prejudice!")
    else
      flash_error("It would be lonely...", "There's only one user, you can't remove the last user - there'd be no-one left to lock the doors and turn the light off!")
    end
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :title)
  end

end
