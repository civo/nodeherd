class MoveDiskFreeToStatistics < ActiveRecord::Migration
  def change
    remove_column :nodes, :disk_free
    rename_column :nodes, :disk_space, :disk_space_gb

    add_column :statistics, :free_disk_gb, :integer
    rename_column :statistics, :free_memory_mb, :free_memory_gb
  end
end
