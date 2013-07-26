#
# Author:: Tom Beynon (tbeynon@rawnet.com)
# Cookbook Name:: backup
# Recipe:: default
#

backup_user = node[:backup][:backup_user]
config = node[:backup][:config]
models = node[:backup][:models]

ohai "reload" do
  action :reload
end

gem_package "backup"
gem_package "whenever"

%w(Backup Backup/models Backup/schedule).each do |dir|
  directory "/home/#{backup_user}/#{dir}" do
    owner backup_user
    recursive true
  end
end

template "/home/#{backup_user}/Backup/config.rb" do
  source "config.rb.erb"
  owner backup_user
  mode 00755
  variables({
              "opts"  => config
            })
end

models.each do |model_name, model_opts|

  opts = model_opts.dup

  template "/home/#{backup_user}/Backup/models/#{model_name}.rb" do
    source "model.rb.erb"
    owner backup_user
    mode 00755
    variables({
                "name"  => model_name,
                "archives" => opts.delete(:archives) || [],
                "databases" => opts.delete(:databases) || [],
                "store_with" => opts.delete(:store_with) || [],
                "notifiers" => opts.delete(:notifiers) || [],
                "encrypt_with" => opts.delete(:encrypt_with) || [],
                "opts"  => opts
              })
  end

  template "/home/#{backup_user}/Backup/schedule/#{model_name}.rb" do
    source "schedule.rb.erb"
    owner backup_user
    mode 00755
    variables({
                "model_name" => model_name,
                "opts"  => model_opts[:schedule]
              })
  end

  execute "whenever" do
    cwd "/home/#{backup_user}/Backup"
    user backup_user
    command "whenever -f schedule/#{model_name}.rb -i '#{model_name}'"
    action :run
  end

end
