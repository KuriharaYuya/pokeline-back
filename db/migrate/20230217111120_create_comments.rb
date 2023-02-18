class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :post_id, null: false
      t.string :user_id, null: false
      t.text :content
      t.timestamps
    end
    add_foreign_key :comments, :users, column: :user_id, primary_key: :id, on_delete: :cascade
    add_foreign_key :comments, :posts, column: :post_id, primary_key: :id, on_delete: :cascade
  end
end
