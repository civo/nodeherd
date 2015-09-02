class AddActionIdToPackageUpdates < ActiveRecord::Migration
  def change
    add_column :package_updates, :action_id, :integer
  end
end
