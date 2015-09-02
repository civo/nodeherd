class ScriptsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :require_login

  def index
    @breadcrumbs.add(scripts_path, "Scripts", "scripts")
    @page_title = "Scripts"
    @page_subtitle = "Random voodoo you run across machines"
    @scripts = Script.not_replaced.not_deleted.page(params[:page])
  end

  def show
    @script = Script.find(params[:id])
    @actions = @script.actions.page(params[:execution_page] || 1)
    @breadcrumbs.add(scripts_path, "Scripts", "scripts")
    @breadcrumbs.add(script_path(@script.id), @script.name, "scripts")
    @page_title = "Script"
    @page_subtitle = "Ready to run this random stuff on your nodes?"
    if params[:node_search]
      @nodes = Node.search(params[:node_search], 1, 10000)
    else
      @nodes = []
    end
  end

  def execute
    @script = Script.find(params[:id])
    if @script.deleted?
      flash_error("Executing", "You can't execute the script '#{@script.name}' because it's been deleted")
      redirect_to script_path(@script.id)
    else
      @nodes = Node.find(params[:nodes])
      @nodes.each do |node|
        node.actions.create(label:"script-execute", script_id: @script.id, completed: false)
      end
      flash_success("Executing", "The script '#{@script.name}' is now running on #{pluralize(@nodes.count, "node")}")
      redirect_to script_path(@script.id)
    end
  end

  def download
    @script = Script.find(params[:id])
    send_data @script.send("file_#{params[:file]}".to_sym),
      filename: @script.send("file_#{params[:file]}_filename"),
      disposition: 'attachment', type: "multipart/related"
  end

  def new
    @breadcrumbs.add(scripts_path, "Scripts", "scripts")
    @page_title = "New Script"
    @page_subtitle = "Here be dragons..."
    @script = Script.new(interpreter: "/bin/bash", timeout: 600)
    render :form
  end

  def create
    @script = Script.new(script_params)
    if @script.valid?
      @script.file_1 = params[:script][:file_1].read rescue nil
      @script.file_1_filename = params[:script][:file_1].original_filename if params[:script][:file_1]
      @script.file_2 = params[:script][:file_2].read rescue nil
      @script.file_2_filename = params[:script][:file_2].original_filename if params[:script][:file_2]
      @script.file_3 = params[:script][:file_3].read rescue nil
      @script.file_3_filename = params[:script][:file_3].original_filename if params[:script][:file_3]
      @script.file_4 = params[:script][:file_4].read rescue nil
      @script.file_4_filename = params[:script][:file_4].original_filename if params[:script][:file_4]
      @script.file_5 = params[:script][:file_5].read rescue nil
      @script.file_5_filename = params[:script][:file_5].original_filename if params[:script][:file_5]
      @script.save

      flash_success("Created", "Your new script '#{@script.name}' has been created")
      redirect_to scripts_path
    else
      render :form
    end
  end

  def edit
    @script = Script.find(params[:id])
    @breadcrumbs.add(scripts_path, "Scripts", "scripts")
    @breadcrumbs.add(script_path(@script.id), @script.name, "scripts")
    @page_title = "Edit Script"
    @page_subtitle = "Are you fixing it or just breaking it further?"
    render :form
  end

  def update
    @old_script = Script.find(params[:id])
    @script = @old_script.dup
    @script.update(script_params)
    if @script.valid?
      @script.file_1 = params[:script][:file_1].read rescue @script.file_1
      @script.file_1_filename = params[:script][:file_1].original_filename if params[:script][:file_1]
      @script.file_2 = params[:script][:file_2].read rescue @script.file_2
      @script.file_2_filename = params[:script][:file_2].original_filename if params[:script][:file_2]
      @script.file_3 = params[:script][:file_3].read rescue @script.file_3
      @script.file_3_filename = params[:script][:file_3].original_filename if params[:script][:file_3]
      @script.file_4 = params[:script][:file_4].read rescue @script.file_4
      @script.file_4_filename = params[:script][:file_4].original_filename if params[:script][:file_4]
      @script.file_5 = params[:script][:file_5].read rescue @script.file_5
      @script.file_5_filename = params[:script][:file_5].original_filename if params[:script][:file_5]
      @script.save

      flash_success("Update", "Your script '#{@script.name}' has been updated, previous executions of the script will still show the old source")
      @old_script.update_attribute(:replaced_by, @script.id)
      redirect_to scripts_path
    else
      render :form
    end
  end

  def destroy
    @script = Script.find(params[:id])
    @script.update_attribute(:deleted, true)
    flash_success("Bang! And the script is gone!", "Your script '#{@script.name}' has been removed, however previous executions of the script will still show the old source")
    redirect_to scripts_path
  end

  private

  def script_params
    params.require(:script).permit(:name, :interpreter, :timeout, :content)
  end

end
