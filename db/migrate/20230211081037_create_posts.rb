class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :pokemon_name
      t.string :version_name
      t.string :pokemon_image
      t.string :title
      t.text :content
      t.string :user_id

      t.timestamps
    end
    add_foreign_key :posts, :users, column: :user_id, primary_key: :id, on_delete: :cascade
  end
end
