class MoveSecurityToPackage < ActiveRecord::Migration
  def change
    remove_column :package_updates, :security
    add_column :packages, :security, :boolean
  end
end
