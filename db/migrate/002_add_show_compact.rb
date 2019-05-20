class AddShowCompact < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hudson_settings, :show_compact, :boolean, :default => false
  end

  def self.down
    remove_column :hudson_settings, :show_compact
  end
end
