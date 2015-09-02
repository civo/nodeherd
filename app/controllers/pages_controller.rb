class PagesController < ApplicationController
  before_filter :require_login

  def index
    @breadcrumbs.add("/", "Dashboard", "dashboard")
    @page_title = "Dashboard"
    @page_subtitle = "Shoving a thermometer up your cloud's bottom"
  end

end
