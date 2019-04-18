class ModifyUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :provider, :string, null: false, default: 'email'
    remove_column :users, :uid, :string, null: false, default: ''
    remove_column :users, :tokens, :json
    remove_column :users, :encrypted_password, :string, null: false, default: ''
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :allow_password_change, :boolean, default: false
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :sign_in_count, :integer, null: false, default: 0
    remove_column :users, :current_sign_in_at, :datetime
    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :inet
    remove_column :users, :last_sign_in_ip, :inet
    remove_column :users, :username, :string, default: ''
    remove_index :users, :email

    add_column :users, :github_name, :string
    add_index :users, :github_name
    add_column :users, :slack_name, :string
    add_column :users, :blacklisted, :boolean, default: false
  end
end
