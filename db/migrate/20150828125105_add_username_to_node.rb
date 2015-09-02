class AddUsernameToNode < ActiveRecord::Migration
  def change
    add_column :nodes, :username, :string, default: "root"
  end
end
