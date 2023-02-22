class CreateArticles < ActiveRecord::Migration[7.0]
  def change
    create_table :articles, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :user_id
      t.string :title
      t.string :genre
      t.text :content

      t.timestamps
    end
    add_foreign_key :articles, :users, column: :user_id, primary_key: :id, on_delete: :cascade
  end
end
