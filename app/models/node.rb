require 'net/ssh/proxy/command'

class Node < ActiveRecord::Base
  has_many :node_tags, dependent: :destroy
  has_many :comments, class_name: "NodeComment", dependent: :destroy
  has_many :actions, dependent: :destroy
  has_many :package_updates, dependent: :destroy

  validates_presence_of :name, :hostname

  def self.refresh_from_juju
    raise Exception.new("Not implemented yet")
  end

  def self.refresh_from_list(node_names)
    Node.all.each do |node|
      if !node_names.include?(node.hostname)
        node.destroy
      else
        node_names.delete(node.hostname)
        node.refresh_hardware
        if node.changed?
          changes = node.changed_attributes.clone
          if changes["lshw_information"]
            changes["lshw_information"] = "Detailed LSHW output"
          end
          node.actions.new(label: "hardware-changed", output: "Changes are:\n\n" + changes.map{|k,v| "- #{k} changed from #{v} to #{node.send(k)}"}.join("\n"), success: true, completed: true)
        end
        node.save
      end
    end
    node_names.each do |node_name|
      node = Node.new(hostname: node_name)
      node.refresh_hardware
      node.actions.new(label: "hardware-new", output: "First time hardware check performed on the node", success: true, completed: true)
      node.save
    end
  end

  def self.check_packages
    Node.all.each do |node|
      node.check_packages
    end
  end

  def self.search(query, page, per_page = 25)
    scope = Node.order(hostname: :asc)
    if query
      query.split(/\s+/).each do |term|
        if term[":"]
          key, value = term.split(":", 2)
          case key
          when "tag"
            scope = scope.joins(:node_tags).where(node_tags:{tag: value})
          end
        else
          scope = scope.where("hostname like ?", "%#{term}%")
        end
      end
    end
    scope.page(page || 1).per(per_page)
  end

  def proxy_username
    proxy.split("@").first
  end

  def proxy_host
    proxy.split("@").second
  end

  def sudo
    username == "root" ? "" : "sudo"
  end

  def ssh_connection
    if proxy.present?
      options = {proxy: Net::SSH::Proxy::Command.new("ssh -i #{Rails.application.config.ssh_key_file} #{proxy} nc %h %p")}
    else
      options = {key_data: Rails.application.config.ssh_key_data}
    end

    Net::SSH.start(hostname, username, options) do |ssh|
      yield ssh
    end
  end

  def test_ssh
    ssh_connection do |ssh|
      puts ssh.exec!("hostname")
    end
  end

  def refresh_hardware
    ssh_connection do |ssh|
      self.cpu_cores = ssh.exec!("cat /proc/cpuinfo | grep siblings | tail -1 | cut -d\":\" -f2").strip.to_i rescue 1
      meminfo = ssh.exec!("free -b | grep \"Mem:\"").split(/\s+/)
      self.ram_bytes = meminfo[1].to_i # Use meminfo[2] + meminfo[6] for free space
      diskinfo = ssh.exec!("df -B1 | grep -E \"/$\"").split(/\s+/)
      self.disk_space_bytes = diskinfo[1].to_i # Use diskinfo[3] for free space
      self.lshw_information = ssh.exec!("lshw -xml")
      lsb_release = Hash[ssh.exec!("cat /etc/lsb-release").split("\n").map {|line| line.split("=") }]
      tags = []
      tags << lsb_release["DISTRIB_CODENAME"]
      tags << hostname.split(".").first.gsub(/\-?\d+$/, "")
      self.os_release = lsb_release["DISTRIB_DESCRIPTION"].gsub('"', "")
      self.tags = tags
    end
  end

  def check_packages
    Net::SSH.start(hostname, 'root', key_data: Rails.application.config.ssh_key_data) do |ssh|
      packages_to_be_upgraded = []
      security_updates = ssh.exec!("grep security /etc/apt/sources.list > /tmp/apt.security.sources.list; #{sudo} apt-get upgrade -f -oDir::Etc::Sourcelist=/tmp/apt.security.sources.list -s | grep Inst") || ""
      security_packages = security_updates.split("\n").map do |security_line|
        if parts = security_line.match(/Inst (\S+) \[(\S+)\] \((\S+)/)
          "#{parts[1]}|#{parts[3]}"
        else
          nil
        end
      end
      security_packages.compact!

      updates = ssh.exec!("#{sudo} apt-get upgrade -f -s | grep Inst") || ""
      updates.split("\n").each do |line|
        if parts = line.match(/Inst (\S+) \[(\S+)\] \((\S+)/)
          package = Package.find_or_create_by(name: parts[1], version: parts[3])
          package.security ||= security_packages.include?("#{parts[1]}|#{parts[3]}")
          package.save
          packages_to_be_upgraded << package.id

          package_update = self.package_updates.find_or_create_by(package_id: package.id)
          package_update.applied ||= false
          package_update.save
        end
      end

      package_updates.where("package_id NOT IN (?)", packages_to_be_upgraded).destroy_all
    end
  end

  def lshw
    @lshw ||= ::Lshw::System.new(Nokogiri::XML(lshw_information))
  end

  def tags
    node_tags.map(&:tag)
  end

  def tags=(names)
    node_tags.destroy_all
    if names.is_a?(String)
      names = names.split(/\s+/)
    end
    names.uniq.each do |name|
      node_tags.new(tag: name.downcase)
    end
  end

  def to_param
    hostname
  end
end
