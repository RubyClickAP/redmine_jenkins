class AddLookAndFeelToHudsonSettings < ActiveRecord::Migration[4.2]
  def self.up
    add_column :hudson_settings, :look_and_feel, :string, :default => "Hudson"
    HudsonSettings.update_all "look_and_feel = 'Hudson'"
  end

  def self.down
    remove_column :hudson_settings, :look_and_feel
  end
end
