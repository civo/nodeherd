class AddNameToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :name, :string
    add_column :nodes, :juju, :boolean, default: false
  end
end
