# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end


every 1.day do
  runner "CommunityMailer.deliver_community_updates"
end

every 1.day do
  runner "ActiveSessionsHelper.cleanup"
end

every 1.day do
  rake "sharetribe:delete_expired_auth_tokens"
end

every 10.minutes do
  rake "sharetribe:synchronize_verified_with_ses"
end

# Learn more: http://github.com/javan/whenever
