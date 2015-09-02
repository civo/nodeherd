class RenameServersToNodes < ActiveRecord::Migration
  def change
    rename_table :servers, :nodes
    rename_table :server_tags, :node_tags
  end
end
