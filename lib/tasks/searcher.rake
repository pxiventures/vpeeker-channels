namespace :vpeeker do

  desc "Long-running task to perform channel searches when required"
  task :searcher => :environment do
    $stdout.sync = true
    while true
      Searcher.perform
      sleep 1
    end
  end

end
