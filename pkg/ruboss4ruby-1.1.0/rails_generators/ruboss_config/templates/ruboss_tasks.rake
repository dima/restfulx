# if the gem is not installed system wide, we'll just skip the tasks
begin
  require 'ruboss4ruby/active_record_tasks'
rescue LoadError
end
