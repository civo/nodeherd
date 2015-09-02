class ReplaceLastOccurrencesOfServer < ActiveRecord::Migration
  def change
    rename_column :queues, :server_id, :node_id
    rename_column :statistics, :server_id, :node_id
    rename_column :node_tags, :server_id, :node_id
    rename_column :package_updates, :server_id, :node_id
  end
end
