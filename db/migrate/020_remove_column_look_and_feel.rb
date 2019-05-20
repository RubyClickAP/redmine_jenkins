class RemoveColumnLookAndFeel < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :hudson_settings, :look_and_feel
  end

  def self.down
    add_column :hudson_settings, :look_and_feel, :string
    HudsonSettings.all.each do |object|
      object.look_and_feel = 'Hudson'
      object.save!
    end
  end
end
