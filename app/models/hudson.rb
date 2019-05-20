# -*- coding: utf-8 -*-

require File.join( File.dirname(__FILE__), 'hudson_api_error' )
require File.join( File.dirname(__FILE__), 'hudson_exceptions' )

class Hudson
  unloadable

  include HudsonHelper
  include RexmlHelper
  
  attr_accessor :project_id, :settings, :jobs
  attr_reader :project, :hudson_api_errors
  

  def api_url_for(type = :user)
    return "" unless @settings
    return "" if @settings.url_for(type) == nil || @settings.url_for(type).length == 0
    return "#{@settings.url_for(type)}api"
  end

  def initialize(project_id)
    @jobs = []
    @project_id = project_id
    @project = Project.find(project_id)
    @settings = HudsonSettings.find_by_project_id(@project_id)

    find_jobs
    clear_hudson_api_errors
  end

  def ci_server_name
    return "" if @settings.url_for(:plugin).blank?
    return HudsonApi.ci_server_name(@settings.url_for(:plugin),
                                    @settings.auth_user,
                                    @settings.auth_password)
  end

  def fetch
    clear_hudson_api_errors

    fetch_jobs

    # 新しいJOBがあるかもしれないので再読み込み
    find_jobs

    return unless @hudson_api_errors.empty?

    fetch_buildresults

  rescue HudsonApiException => error
    @hudson_api_errors << HudsonApiError.new(self.class.name, "fetch", error)
  end

  def get_job(job_name)
      job = self.jobs.find{|job| job.name == job_name}
      return HudsonNoJob.new(:name => job_name, :settings => @settings) unless job
      return job
  end

  def add_job(job_name)
    tmpa = []
    Rails.logger.info "  ==>[add_jobs]"
    retval = HudsonJob.new()
    Rails.logger.info "  ==>  retval: " + retval.inspect
    retval.name = job_name
    retval.project_id = self.project_id
    retval.hudson_id = self.settings.id
    retval.project = self.project
    Rails.logger.info "  ==>  self.jobs: " + self.jobs.inspect
    #self.jobs << retval
    tmpa << retval
    #self.jobs.push(retval)    
    return retval
  end

private
  def clear_hudson_api_errors
    @hudson_api_errors = []
  end

  def fetch_jobs
    content = ""
    begin
      content = HudsonApi.get_job_details(self.api_url_for(:plugin), @settings.auth_user, @settings.auth_password)
    rescue HudsonApiException => error
      raise error
    end

    doc = REXML::Document.new content

    doc.elements.each("hudson/job") do |element|
      job_name = get_element_value(element, "name")
      next unless self.settings.job_include?(job_name)

      job = self.get_job(job_name)
      job = add_job(job_name) if job.is_a?(HudsonNoJob)
      
      job.update_by_xml(element)
      job.update_health_report_by_xml(element)
      job.save!
    end

  end

  def fetch_buildresults
    
    self.jobs.each do |job|
      next unless self.settings.job_include?(job.name)

      job.fetch_builds

      @hudson_api_errors += job.hudson_api_errors unless job.hudson_api_errors.empty?

    end

  end

  def find_jobs
    Rails.logger.info "  ==>[find_jobs]"
    #Rails.logger.info "  ==>  project_id: " + project_id.to_s
    tmp = HudsonJob.where(:project_id => @project_id).order(:name).includes(:job_settings)
    Rails.logger.info "  ==? jobs:: " + tmp.inspect
    @jobs = HudsonJob.where(:project_id => @project_id).order(:name).includes(:job_settings)
  end

end

def Hudson.find(*args)
  case args.first
    when :all   then
      retval = []
      HudsonSettings.where(*args).each do |settings|
        next unless Project.find_by_id(settings.project_id)
        retval << Hudson.new(settings.project_id)
      end
      return retval
    else
      settings = HudsonSettings.where(*args)
      return nil unless Project.find_by_id(settings.project_id)
      retval = Hudson.new(settings.project_id)
      return retval
  end
end

def Hudson.find_by_project_id(project_id)
  retval = Hudson.new(project_id)
  return retval
end

def Hudson.fetch
  all.each do |hudson|
    hudson.fetch
    next if hudson.hudson_api_errors.empty?
    hudson.hudson_api_errors.each do |error|
      $stderr.print "redmine_jenkins: #{hudson.project.name}(#{hudson.settings.url_for(:plugin)}) #{error.class_name}:#{error.method_name} #{error.exception.message}\n"
    end
  end
end

def Hudson.autofetch?
  return false unless Setting.plugin_redmine_jenkins['autofetch']
  return false if Setting.plugin_redmine_jenkins['autofetch'] == ""
  return true
end

def Hudson.job_description_format
  return "hudson" unless Setting.plugin_redmine_jenkins['job_description_format']
  return "hudson" if Setting.plugin_redmine_jenkins['job_description_format'] == ""
  return Setting.plugin_redmine_jenkins['job_description_format']
end

def Hudson.query_limit_builds_each_job
  return 100 unless Setting.plugin_redmine_jenkins['query_limit_builds_each_job']
  return 100 if Setting.plugin_redmine_jenkins['query_limit_builds_each_job'] !~ /^[0-9]+$/
  return Setting.plugin_redmine_jenkins['query_limit_builds_each_job'].to_i
end

def Hudson.query_limit_changesets_each_job
  return 100 unless Setting.plugin_redmine_jenkins['query_limit_changesets_each_job']
  return 100 if Setting.plugin_redmine_jenkins['query_limit_changesets_each_job'] !~ /^[0-9]+$/
  return Setting.plugin_redmine_jenkins['query_limit_changesets_each_job'].to_i
end

