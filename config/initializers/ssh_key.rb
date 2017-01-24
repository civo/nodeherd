if File.exist?(Rails.root.join("config", "ssh.yml"))
  ssh_key_file =  YAML.load(ERB.new(File.read("#{Rails.root}/path_to_your_file.yml.erb")).result)[Rails.env][:filename]
elsif ENV["NODEHERD_PRIVATE_SSH_KEY_FILENAME"]
  ssh_key_file = ENV["NODEHERD_PRIVATE_SSH_KEY_FILENAME"]
else
  ssh_key_file = "#{Dir.home}/.ssh/id_dsa"
end

if File.exist?(ssh_key_file)
  Rails.application.config.x.ssh_key_file = ssh_key_file
  Rails.application.config.x.ssh_key_data = File.read(ssh_key_file)
end
