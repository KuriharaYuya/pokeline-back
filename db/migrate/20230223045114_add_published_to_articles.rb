class AddPublishedToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :published, :boolean, default: false
  end
end
