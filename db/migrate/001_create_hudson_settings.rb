class CreateHudsonSettings < ActiveRecord::Migration[4.2]
  def self.up
    create_table :hudson_settings do |t|
      t.integer :project_id
      t.string :url, :null => false
      t.string :job_filter, :null => true
    end
  end

  def self.down
    drop_table :hudson_settings
  end
end
