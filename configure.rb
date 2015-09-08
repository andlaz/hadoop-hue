require "thor"
require "erb"
require "securerandom"

class Configure < Thor
 
  # ...
  def self.exit_on_failure?
    true
  end 
  
  class << self
    def options(options={})
      
      options.each do |option_name, option_settings|
        option option_name, option_settings  
      end
  
    end
  end
  
  module ERBRenderer
    
    def render_from(template_path)
      ERB.new(File.read(template_path), 0, '<>').result binding
    end
    
  end
  
  class HueConfiguration
    include ERBRenderer
    attr_accessor :secret_key,
      :time_zone,
      :hdfs_default_fs,
      :oozie_url,
      :yarn_resource_manager_host,
      :yarn_resource_manager_port,
      :yarn_resource_manager_url,
      :yarn_proxy_server_url,
      :yarn_history_server_url

  end
 
  desc "hue", "Configure HUE"
  option :time_zone, :default => "Europe/Budapest", :desc => "Time zone of the Hue install"
  option :hdfs_default_fs, :required => true, :desc => "HDFS url to use"
  option :yarn_resource_manager_host, :required => true, :desc => "YARN Resource Manager host"
  option :yarn_resource_manager_port, :default => 8032, :required => true, :desc => "YARN Resource Manager data port"
  option :yarn_resource_manager_url, :required => true, :desc => "YARN Resource Manager API URL"
  option :yarn_proxy_server_url, :required => true, :desc => "YARN Application Proxy URL"
  option :yarn_history_server_url, :required => true, :desc => "YARN History Server URL"
  option :oozie_url, :desc => "Oozie URL, if available"
  def hue
    
    configuration = HueConfiguration.new
    
    configuration.secret_key = SecureRandom.urlsafe_base64
    configuration.time_zone = options[:time_zone]
    configuration.hdfs_default_fs = options[:hdfs_default_fs]
    configuration.yarn_resource_manager_host = options[:yarn_resource_manager_host]
    configuration.yarn_resource_manager_port = options[:yarn_resource_manager_port]
    configuration.yarn_resource_manager_url = options[:yarn_resource_manager_url]
    configuration.yarn_proxy_server_url = options[:yarn_proxy_server_url]
    configuration.yarn_history_server_url = options[:yarn_history_server_url]
    configuration.oozie_url = options[:oozie_url]
    
    File.write '/etc/hue/desktop.ini',
      configuration.render_from('/etc/hue/desktop.ini.erb')
      
    File.write '/etc/hue/hdfs.ini',
      configuration.render_from('/etc/hue/hdfs.ini.erb')
      
    File.write '/etc/hue/oozie.ini',
      configuration.render_from('/etc/hue/oozie.ini.erb')
      
    File.write '/etc/hue/yarn.ini',
      configuration.render_from('/etc/hue/yarn.ini.erb')
      
  end


  protected
  def skim(options, keys)
    
    return options.inject({}) { |h, (k, v)| if (h != nil && (keys.include? k.to_sym)) then h[k.to_sym] = v end; h }
    
  end
  
end

Configure.start(ARGV)
