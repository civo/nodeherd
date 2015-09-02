class PackagesController < ApplicationController
  before_filter :require_login

  def index
    @breadcrumbs.add(upgrades_path, "Upgrades", "packages")
    @page_title = "Package Upgrades"
    @page_subtitle = "Any poorly cattle out there, that need a shot?"
    @package_updates = PackageUpdate.not_applied.includes(:package).joins(:package)
    @package_updates = @package_updates.where("packages.name like ?", "%#{params[:search]}%") if params[:search].present?
    @packages = Kaminari.paginate_array(@package_updates.map(&:package).uniq).page(params[:page])
  end

  def show
    @package = Package.find(params[:id])
    @package.retrieve_information if @package.information.blank?
    @current_updates = @package.package_updates.includes(:node).where("action_id IS NOT NULL")
    counts = @current_updates.map(&:applied)
    @update_status = {applied: counts.select{|i| i == true}.size, total: counts.size}
    @updates = @package.package_updates.includes(:node).order(applied: :desc)
    @breadcrumbs.add(upgrades_path, "Upgrades", "packages")
    @breadcrumbs.add(package_path(@package.id), @package.name, "packages")
    @page_title = "#{@package.name} #{@package.version}"
    @page_subtitle = "Extra, extra, read all about it!"
  end

  def nodes
    @package = Package.find(params[:id])
    @nodes = @package.package_updates.map(&:node)
    @breadcrumbs.add(upgrades_path, "Upgrades", "packages")
    @breadcrumbs.add(package_path(@package.id), @package.name, "packages")
    @breadcrumbs.add(package_nodes_path(@package.id), @package.name, "packages")
    @page_title = "Nodes for #{@package.name} #{@package.version}"
    @page_subtitle = "Packagebots, roll out..."
  end

  def apply
    @package = Package.find(params[:id])
    @package.package_updates.each do |update|
      next unless params[:nodes].include?(update.node.id.to_s)
      action = update.node.actions.create(label:"package-upgrade", package_id: @package.id, completed: false)
      update.action_id = action.id
      update.save
    end
    redirect_to package_path(@package.id)
  end

  def update_status
    @package = Package.find(params[:id])
    @current_updates = @package.package_updates.includes(:node).where("action_id IS NOT NULL")
    counts = @current_updates.map(&:applied)
    @update_status = {applied: counts.select{|i| i == true}.size, total: counts.size}
    @updates = @package.package_updates.includes(:node).order(applied: :desc)
    render partial: "update_status"
  end
end
