class StatsController < ActionController::Base
  def index
    data = {}
    data[:regular] = PackageUpdate.by_package(PackageUpdate.not_applied.not_security).count
    data[:security] = PackageUpdate.by_package(PackageUpdate.not_applied.security).count
    render json: data
  end
end
