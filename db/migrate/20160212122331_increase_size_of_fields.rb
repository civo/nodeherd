class IncreaseSizeOfFields < ActiveRecord::Migration
  def change
    change_column :nodes, :ram_bytes, :integer, limit: 8
    change_column :nodes, :disk_space_bytes, :integer, limit: 8
  end
end
