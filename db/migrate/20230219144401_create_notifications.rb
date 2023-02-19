class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :visitor_id, null: false
      t.string :visited_id, null: false
      t.string :post_id, null: false
      t.string :comment_id
      t.string :action, null: false
      t.boolean :checked, default: false

      t.timestamps
    end
  end
end
