class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: false do |t|
      t.string :uid, null: false, primary_key: true
      t.string :name
      t.string :picture
      t.string :email

      t.timestamps
    end
  end
end
