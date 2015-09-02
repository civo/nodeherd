namespace :actions do
  desc "Reset last action"
  task :reset_last => :environment do
    Action.last.reset
  end

  desc "Run once through and quit"
  task :run_once => :environment do
    Action.run_once
  end

  desc "Run forever, sleeping between runs"
  task :run => :environment do
    while true do
      Action.run_once
      sleep(1)
    end
  end
end
