env :PATH, ENV['PATH']
set :bundle_command, "/root/.rbenv/shims/bundle exec"

set :environment, "production"
set :output, {:error => "log/cron_error_log.log", :standard => "log/cron_log.log"}

every :minute do
  rake "divider:perform"
end
