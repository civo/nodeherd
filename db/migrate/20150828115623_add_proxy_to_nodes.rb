class AddProxyToNodes < ActiveRecord::Migration
  def change
    remove_column :nodes, :juju
    add_column :nodes, :proxy, :string
  end
end
