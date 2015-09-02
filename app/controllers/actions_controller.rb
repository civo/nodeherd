class ActionsController < ApplicationController
  before_filter :require_login

  def output
    action = Action.find(params[:id])
    render text: "<pre><code>#{action.output}</code></pre>"
  end

  def index
    @breadcrumbs.add(nodes_path, "Changelog", "logs")
    @page_title = "Changelog"
    @page_subtitle = "What's going' on 'ere den?"
    @actions = Action.latest.page(params[:page] || 1)
  end

  def show
    @action = Action.find(params[:id])
    @breadcrumbs.add(nodes_path, "Changelog", "logs")
    @page_title = "Log Entry #{@action.id}"
    @page_subtitle = "It did what...?"
  end
end
