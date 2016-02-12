class NodesController < ApplicationController
  before_filter :require_login, except: [:register]
  protect_from_forgery except: :register

  def index
    @breadcrumbs.add(nodes_path, "Nodes", "nodes")
    @page_title = "Nodes"
    @page_subtitle = "A birds-eye view of your farm"
    @nodes = Node.search(params[:search], params[:page]).order(name: :asc)
  end

  def show
    @node = Node.find_by(hostname: params[:hostname])
    if @node
      @breadcrumbs.add(nodes_path, "Nodes", "nodes")
      @breadcrumbs.add(nodes_path, @node.hostname.split(".").first, "nodes")
      @page_title = @node.hostname
      @page_subtitle = "One poor little node, all by itself..."
    else
      flash_error("Not found", "Could not find a node called #{params[:hostname]}")
      redirect_to nodes_path
    end
  end

  def comment
    @node = Node.find_by(hostname: params[:hostname])
    @node.comments.create!(comment: params[:comment], user_id: @current_user.id)
    flash_success("Thank you", "Your comment has been successfully recorded for #{@node.hostname}")
    redirect_to node_path(@node.hostname)
  end

  def tag
    @node = Node.find_by(hostname: params[:hostname])
    tags = @node.tags
    if tags.include?(params[:tag])
      tags.delete(params[:tag])
      flash_success("Removed", "The tag #{params[:tag]} no longer applies to #{@node.hostname}")
    else
      tags += [params[:tag]]
      flash_success("Removed", "The node #{@node.hostname} is now tagged with #{params[:tag]}")
    end
    @node.tags = tags
    @node.save
    redirect_to node_path(@node.hostname)
  end

  def new
    @node = Node.new
  end

  def create
    params[:node][:hostname] = params[:node][:name] if params[:node][:hostname].blank?
    @node = Node.new(node_params)
    if @node.save
      flash_success("Created", "The node #{@node.hostname} has been created")
      redirect_to node_path(@node.hostname)
    else
      render :new
    end
  end

  def edit
    @node = Node.find_by(hostname: params[:hostname])
  end

  def update
    params[:node][:hostname] = params[:node][:name] if params[:node][:hostname].blank?
    @node = Node.find_by(hostname: params[:hostname])
    if @node.update_attributes(node_params)
      flash_success("Updated", "The node #{@node.hostname} has been updated")
      redirect_to node_path(@node.hostname)
    else
      render :edit
    end
  end

  def destroy
    @node = Node.find_by(hostname: params[:hostname])
    if @node.destroy
      flash_success("Removed", "The node #{@node.hostname} has been removed")
      redirect_to nodes_path
    else
      flash_success("Unable to find", "The node #{@node.hostname} could not be removed as its no longer in Nodeherd")
      redirect_to nodes_path
    end
  end

  def register
    params["hostname"] ||= params["name"]
    params["name"] ||= params["hostname"]
    @node = Node.find_by(hostname: params["hostname"])
    if @node
      original_tags = @node.tags
      new_tags = params.delete("tags").split(/\s+/)
      @node.assign_attributes(node_registration_params)
      if @node.changed? || (new_tags - original_tags) != []
        @node.tags = @node.tags + new_tags
        @node.save
        render json: {success: true, message: "Updated node"}
      else
        render json: {success: true, message: "Node hasn't changed"}
      end
    else
      @node = Node.create(node_registration_params)
      if @node.persisted?
        render json: {success: true, message: "Node created"}
      else
        render json: {success: false, message: "Unable to create the node, did you definitely supply at least a hostname?"}
      end
    end
  end

  private

  def node_params
    params.require(:node).permit(:name, :hostname, :proxy, :tags, :username)
  end

  def node_registration_params
    params.permit(:name, :hostname, :proxy, :tags, :username)
  end
end
