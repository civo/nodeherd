class AddCommentsToNodes < ActiveRecord::Migration
  def change
    create_table :node_comments do |t|
      t.integer :node_id
      t.integer :user_id
      t.string :comment
      t.timestamps
    end
  end
end
