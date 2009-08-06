set :application, "urlagg"
set :repository, "git@github.com:jschoolcraft/urlagg.git"
set :user, "jeff"
set :use_sudo, true
set :git_enable_submodules, false
set :deploy_via, :fast_remote_cache

set :keep_releases, 6

set :config_files, %w(database.yml newrelic.yml initializers/hoptoad.rb)
namespace :deploy do
  desc 'symlink config files'
  task :link_config, :roles => :app do
    unless config_files.empty?
      config_files.each do |file|
        run "ln -nsf #{File.join(shared_path, "system/config/" + file)} #{File.join(release_path, "/config/" + file)}"
      end
    end
  end
end

after "deploy:update", "deploy:cleanup"
after "deploy:update_code", "deploy:link_config"

namespace :sass do
  desc 'Updates the stylesheets generated by Sass'
  task :update, :roles => :app do
    invoke_command "cd #{latest_release}; RAILS_ENV=#{rails_env} rake sass:update"
  end

  # Generate all the stylesheets manually (from their Sass templates) before each restart.
  before 'deploy:restart', 'sass:update'
end