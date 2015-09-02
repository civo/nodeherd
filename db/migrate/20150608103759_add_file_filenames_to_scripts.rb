class AddFileFilenamesToScripts < ActiveRecord::Migration
  def change
    add_column :scripts, :file_1_filename, :string
    add_column :scripts, :file_2_filename, :string
    add_column :scripts, :file_3_filename, :string
    add_column :scripts, :file_4_filename, :string
    add_column :scripts, :file_5_filename, :string
  end
end
