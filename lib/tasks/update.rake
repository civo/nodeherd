namespace :update do
  desc "Update the list of nodes from the static list"
  task :nodes_from_static => :environment do
    Node.refresh_from_list(%w{git.absolutedevops.io})
  end

  desc "Update the list of nodes from a random set"
  task :nodes_from_random => :environment do
    list = (0..100).map {|i| "web-#{i}.ngdapp.co.uk"}
    Node.refresh_from_list(list)
  end

  desc "Get all statistics updated"
  task :statistics => :environment do
    Node.gather_statistics
  end

  desc "Package update check"
  task :packages => :environment do
    Node.check_packages
  end

  desc "Hardware check"
  task :hardware => :environment do
    Node.all.each do |node|
      node.refresh_hardware
      node.save(validate: false)
    end
  end
end
