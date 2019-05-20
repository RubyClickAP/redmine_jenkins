class CreateHudsonJobs < ActiveRecord::Migration[4.2]
  def self.up
    create_table :hudson_jobs do |t|
      t.integer :project_id
      t.integer :hudson_id
      t.string  :name, :null => false
      t.string  :latest_build_number
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :hudson_builds do |t|
      t.column :hudson_job_id, :integer
      t.column :number, :string
      t.column :result, :string
      t.column :finished_at, :datetime
      t.column :building, :string
      t.column :error, :string
    end

    create_table :hudson_build_changesets do |t|
      t.column :hudson_build_id, :integer
      t.column :repository_id, :integer
      t.column :revision, :string
      t.column :error, :string
    end
  end

  def self.down
    drop_table :hudson_jobs
    drop_table :hudson_builds
    drop_table :hudson_build_changesets
  end
end
