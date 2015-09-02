class Package < ActiveRecord::Base
  has_many :package_updates
  serialize :information

  def retrieve_information
    node = package_updates.first.node
    node.ssh_connection do |ssh|
      apt_info = ssh.exec!("#{node.sudo} apt-cache show #{self.name}").split("\n\n")[0]
      last_key = nil
      self.information = {}
      apt_info.split("\n").each do |line|
        if line[/^ /]
          self.information[last_key] += line
        else
          last_key, value = line.split(": ")
          self.information[last_key] = value
        end
      end
    end
    save
  end
end
