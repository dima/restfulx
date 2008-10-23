require 'find'

namespace :db do
  desc "runs db:refresh in the latest release directory."  
  task :refresh, :roles => :db do
     run("cd #{latest_release} && rake db:refresh RAILS_ENV=production")
  end
end

namespace :deploy do
  namespace :flex do

    desc "uploads everything in public/bin up to the server"
    task :via_dumb_copy, :roles => :app do
      # the -p flag on mkdir makes intermediate directories (i.e. both /bin and /bin/history), 
      # and doesn't raise an error if any of the directories already exist.
      rails_root = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
      base_dir = File.join(rails_root, 'public', 'bin')
      ec2_base_dir = File.join(shared_path, 'flex_files')
    
      Find.find(base_dir) do |file| 
        filename_without_base_dir = file.sub(base_dir, '')
        if File.directory?(file)
          run "mkdir -p #{File.join(ec2_base_dir, filename_without_base_dir)}"
        else
          content = File.open(file, 'rb') {|f| f.read}
          put content, File.join(ec2_base_dir, filename_without_base_dir)
        end
      end
    end

    desc "synchronizes the local and remote public/bin directories using rsync"
    task :via_rsync, :roles => :app do      
      username = user || ENV['USER']
      rails_root = File.join(File.dirname(__FILE__), '..', '..', '..', '..')
      execute_on_servers do |server|
        `rsync -r -p -v -e \"ssh -i #{ssh_options[:keys]}\" #{File.join(rails_root, 'public', 'bin')}/ #{username}@#{server}:#{File.join(shared_path, 'flex_files')}/`
      end
    end
  
    task :make_symlink, :roles => :app do
      run "ln -s #{shared_path}/flex_files #{release_path}/public/bin"
    end
  
  end
end
  