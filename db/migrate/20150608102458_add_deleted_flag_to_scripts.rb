class AddDeletedFlagToScripts < ActiveRecord::Migration
  def change
    add_column :scripts, :deleted, :boolean, default: false
  end
end
