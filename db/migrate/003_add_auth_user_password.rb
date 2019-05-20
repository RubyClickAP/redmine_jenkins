class AddAuthUserPassword < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hudson_settings, :auth_user, :string, :default => ''
    add_column :hudson_settings, :auth_password, :string, :default => ''
  end

  def self.down
    remove_column :hudson_settings, :auth_user
    remove_column :hudson_settings, :auth_password
  end
end
