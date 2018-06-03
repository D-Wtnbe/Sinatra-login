class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :userid
      t.string :password
      t.string :name
      t.string :email
      t.timestamps null: false
      t.integer :user_id
    end
end
end
