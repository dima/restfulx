# if the gem is not installed system wide, we'll just skip the tasks
begin
  # this will load the latest restfulx gem version
  require 'restfulx/active_record_tasks'
rescue LoadError
end
