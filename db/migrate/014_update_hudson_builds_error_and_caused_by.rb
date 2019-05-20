require File.join(File.dirname(__FILE__), "../../app/models", 'hudson_build')

class UpdateHudsonBuildsErrorAndCausedBy < ActiveRecord::Migration[4.2]
  def self.up
    HudsonBuild.where("error IS NULL").update_all("error = ''")
    HudsonBuild.where("caused_by IS NULL").update_all("caused_by = 1")
  end

  def self.down
  end
end
