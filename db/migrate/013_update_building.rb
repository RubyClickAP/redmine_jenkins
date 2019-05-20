require File.join(File.dirname(__FILE__), '../../app/models', 'hudson_build')

class UpdateBuilding < ActiveRecord::Migration[4.2]
  def self.up
    HudsonBuild.where("building = 't'").update_all("building = 'true'")
    HudsonBuild.where("building = 'f'").update_all("building = 'false'")
  end

  def self.down
    HudsonBuild.where("building = 'true'").update_all("building = 't'")
    HudsonBuild.where("building = 'false'").update_all("building = 'f'")
  end
end
