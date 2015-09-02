class Action < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  belongs_to :node
  belongs_to :package
  belongs_to :script
  has_many :package_updates
  scope :completed, ->() { where(completed: true) }
  scope :not_completed, ->() { where(completed: false) }
  scope :latest, ->() { order(created_at: :desc).limit(1000) }

  def self.run_once
    Action.not_completed.each do |action|
      action.process
    end
  end

  def icon(color_type = "bg")
    colour = "#{color_type}-green"
    colour = "#{color_type}-red" unless success?
    colour = "#{color_type}-orange" unless completed?

    # TODO: Add alt tags
    ret = if label == "hardware-changed"
      "<i class=\"fa fa-cog #{colour}\" title='Hardware changed'></i>"
    elsif label == "hardware-new"
      "<i class=\"fa fa-cog #{colour}\" title='Hardware discovered'></i>"
    elsif label == "package-upgrade"
      "<i class=\"fa fa-gift #{colour}\" title='Package upgraded'></i>"
    elsif label == "script-execute"
      "<i class=\"fa fa-book #{colour}\" title='Script executed'></i>"
    else
      ""
    end
    ret.html_safe
  end

  def title
    ret = if label == "hardware-changed"
      "Hardware changed"
    elsif label == "hardware-new"
      "Hardware determined"
    elsif label == "package-upgrade" && completed?
      "Upgraded #{package.name} to #{package.version}"
    elsif label == "package-upgrade"
      "Upgrading #{package.name} to #{package.version}"
    elsif label == "script-execute" && completed?
      "Executed #{link_to script.name, script_path(script)}"
    elsif label == "script-execute"
      "Executing #{link_to script.name, script_path(script)}"
    else
      ""
    end
    ret.html_safe
  end

  def process
    case label
    when "package-upgrade"
      process_package_upgrade
    when "script-execute"
      process_script_execute
    end
  end

  def reset
    self.success = nil
    self.output = nil
    self.completed = false
    self.save
  end

  def process_package_upgrade
    exit_code = 0
    self.output = ""
    node.ssh_connection do |ssh|
      channel = ssh.exec("#{node.sudo} apt-get update >/dev/null 2>&1; #{node.sudo} apt-get install #{package.name}=#{package.version}") do |ch, success|
        channel.on_data do |_, data|
          self.output += data
        end

        channel.on_extended_data do |_, _, data|
          self.output += data
        end

        channel.on_request("exit-status") do |_, data|
          exit_code = data.read_long
        end
      end
      channel.wait
      self.success = (exit_code == 0)
      self.completed = true
      self.package_updates.each do |package_update|
        package_update.update_attribute(:applied, true)
      end
      save
    end
  end

  def script_sudo
    "sudo " if sudo?
  end

  def process_script_execute
    if node.proxy
      ssh_options = {proxy: Net::SSH::Proxy::Command.new("ssh -i #{Rails.application.config.ssh_key_file} #{node.proxy} nc %h %p")}
    else
      ssh_options = {key_data: Rails.application.config.ssh_key_data}
    end

    uploaded_files = {}
    (1..5).each do |n|
      if script.send("file_#{n}".to_sym).present?
        remote_filename = "/tmp/#{SecureRandom.uuid}"
        uploaded_files["NODEHERD_ATTACHMENT_#{n}"] = remote_filename
        Net::SCP.upload!(node.hostname, node.username,
          StringIO.new(script.send("file_#{n}".to_sym)), remote_filename,
          ssh: ssh_options)
      end
    end

    script_filename = "/tmp/#{SecureRandom.uuid}"
    Net::SCP.upload!(node.hostname, node.username,
      StringIO.new("\#!#{script.interpreter}\n#{script.content.gsub("\r", "")}\n"), script_filename,
      ssh: ssh_options)

    exit_code = 0
    self.output = ""
    Net::SSH.start(node.hostname, node.username, ssh_options) do |ssh|
      ssh.exec!("chmod +x #{script_filename}")

      uploaded_files_env = uploaded_files.map {|k,v| "#{k}=#{v}"}.join(" ")
      command = "#{" " + uploaded_files_env if uploaded_files_env.present?}#{script_sudo} #{script_filename} 2>&1" + " ; rm -f #{script_filename}"
      uploaded_files.each do |k,v|
        command += " ; rm -f #{uploaded_files[k]}"
      end

      block ||= Proc.new do |ch, type, data|
        ch[:result] ||= ""
        ch[:result] << data
      end

      channel = ssh.exec(command, &block)
      channel.on_request("exit-status") do |_, data|
        exit_code = data.read_long
      end
      channel.wait
      self.output = channel[:result]

      if exit_code == 126
        self.output += "Unable to execute #{script.interpreter}"
      end

      self.success = (exit_code == 0)
      self.completed = true
      save
    end

  end
end
