class AddFieldsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :github_name, :string
    add_index :users, :github_name
    add_column :users, :slack_name, :string
    add_column :users, :blacklisted, :boolean, default: false
  end
end
