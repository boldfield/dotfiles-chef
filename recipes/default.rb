#
# Cookbook Name:: dotfiles
# Recipe:: default
#
# Copyright (C) 2016 Brian Oldfield
#
#
# /Users/boldfield/Library/Preferences/com.mizage.Divvy.plist
#
# /Users/boldfield/.dotfiles/Library/Preferences/com.mizage.Divvy.plist

home_dir = case node.platform
              when 'mac_os_x'
                "/Users/#{node['dotfiles']['user']}"
              else
                "/home/#{node['dotfiles']['user']}"
              end
install_dir = "#{home_dir}/.dotfiles"

group = case node.platform
        when 'mac_os_x'
          'staff'
        else
          node['dotfiles']['user']
        end

git install_dir do
  repository node['dotfiles']['install']['src']['repository']
  revision node['dotfiles']['install']['src']['revision']
  action :checkout
  user node['dotfiles']['user']
  group group
end

['global', node.platform].each do |tgt|
  tgt_dir = "#{install_dir}/#{tgt}"
  next unless ::Dir.exist?(tgt_dir)
  Dotfiles.evaluate_links(home_dir, tgt_dir).each do |name, path, target|
    # Create parent directory for links if required
    unless path == home_dir
      directory "#{path}" do
        recursive true
        owner node['dotfiles']['user']
        group group
      end
    end

    # Intentionally letting this fail if a file already exists at the target
    # until there's a better way to deal
    link "#{path}/#{name}" do
      to target
      owner node['dotfiles']['user']
      group group
    end
  end

  Dotfiles.evaluate_directories(home_dir, tgt_dir).each do |name, path, _|
    directory "#{path}/#{name}" do
      recursive true
      owner node['dotfiles']['user']
      group group
    end
  end
end
