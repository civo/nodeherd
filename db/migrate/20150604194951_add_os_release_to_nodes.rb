class AddOsReleaseToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :os_release, :string
  end
end
