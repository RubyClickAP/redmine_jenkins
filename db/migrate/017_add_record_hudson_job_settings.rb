class AddRecordHudsonJobSettings < ActiveRecord::Migration[4.2]
  def self.up
    HudsonJob.all.each do |job|
      settings = HudsonJobSettings.new
      settings.hudson_job_id = job.id
      settings.save!
    end
  end

  def self.down

  end
end
