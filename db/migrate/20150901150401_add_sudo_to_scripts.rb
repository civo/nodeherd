class AddSudoToScripts < ActiveRecord::Migration
  def change
    add_column :scripts, :sudo, :boolean, default: false
  end
end
