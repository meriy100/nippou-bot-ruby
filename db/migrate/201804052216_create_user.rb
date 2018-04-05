class CreateUser < ActiveRecord::Migration[5.0]
  def self.up
    create_table :users do |t|
      t.string :slack_name
      t.string :github_id
      t.string :github_token
      t.string :esa_token
      t.string :esa_name

      t.timestamps  # => これでcreated_atとupdated_atカラムが定義される
    end
  end

  def self.down
    drop_table :users
  end
end
