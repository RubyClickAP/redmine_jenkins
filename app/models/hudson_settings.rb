# coding: utf-8

class HudsonSettings < ActiveRecord::Base
  unloadable

  include I18n
  
  include Redmine::SafeAttributes

  belongs_to :project
  
  has_many :health_report_settings, :class_name => 'HudsonSettingsHealthReport', :dependent => :destroy

  #attr_accessor :url, :url_for_plugin, :auth_user, :auth_password
  #attr_accessor :get_build_details, :show_compact
  #attr_accessor :jobs
  
  scope :by_project, lambda { |project_id| where(:project_id => project_id) unless project_id.blank? }

  validates_presence_of   :project_id, :url
  validates_uniqueness_of :project_id
  
  attr_protected :id if ActiveRecord::VERSION::MAJOR <= 4
  safe_attributes 'url',
                  'url_for_plugin',
                  'project_id',
                  'auth_user',
                  'auth_password',
                  'get_build_details',
                  'show_compact',
                  'jobs'

  DELIMITER = ','

  @@HUMANIZED_ATTRIBUTE_KEY_NAMES = {
    "health_report_settings" => I18n.t(:label_health_report_settings)
  }

  def self.human_attribute_name(attribute_key_name)
    @@HUMANIZED_ATTRIBUTE_KEY_NAMES[attribute_key_name] || super
  end

  def self.find_by_project_id(project_id)
    retval = HudsonSettings.find_by(:project_id => project_id)
    retval = HudsonSettings.new() if retval == nil
    return retval
  end

  def url=(value)
    write_attribute :url, add_last_slash(value)
  end

  def url_for_plugin=(value)
    write_attribute :url_for_plugin, add_last_slash(value)
  end

  def jobs=(value)
    write_attribute :job_filter, to_value(value)
  end

  def jobs
    #logger.info "  ==> jobs: " + read_attribute(:job_filter).inspect
    to_array(read_attribute(:job_filter))
  end

  def use_authentication?
    return false unless self.auth_user
    return false unless self.auth_user.length > 0
    return true
  end

  def job_include?(other)
    return false if self.job_filter == nil
    value = to_array( self.job_filter )
    return value.include?(other.to_s)
  end

  def url_for(type)
    return self.url_for_plugin if type == :plugin and self.url_for_plugin and self.url_for_plugin.length > 0
    return self.url
  end

  def add_last_slash(value)
    added = value
    return "" unless added
    return "" if added.length == 0
    added += "/" unless added.index(/\/$/)
    return added
  end

  def to_value(value)
    return "" if value == nil
    return value.join(HudsonSettings::DELIMITER)
  end

  def to_array(value)
    return [] if value == nil
    logger.info "  ==> value: " + value
    #logger.info "  ==>" + HudsonSettings::DELIMITER
    logger.info "  ==>" + value.split(HudsonSettings::DELIMITER).inspect
    return value.split(HudsonSettings::DELIMITER)
  end

end

