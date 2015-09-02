class RenameQueuesToActions < ActiveRecord::Migration
  def change
    rename_table :queues, :actions
    rename_column :actions, :action, :label
  end
end
