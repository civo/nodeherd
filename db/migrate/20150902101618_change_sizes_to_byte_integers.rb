class ChangeSizesToByteIntegers < ActiveRecord::Migration
  def change
    remove_column :nodes, :ram_gb
    remove_column :nodes, :disk_space_gb
    add_column :nodes, :ram_bytes, :integer
    add_column :nodes, :disk_space_bytes, :integer
  end
end
