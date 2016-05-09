#
# Cookbook Name:: dotfiles
# Recipe:: default
#
# Copyright (C) 2016 Brian Oldfield
#
#
home_dir = case node.platform_family
              when 'mac_os_x'
                "/Users/#{node['dotfiles']['user']}"
              else
                "/home/#{node['dotfiles']['user']}"
              end
install_dir = "#{home_dir}/.dotfiles"

group = case node.platform_family
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

# Support links nested up to two dirs deep
(0..2).each do |i|
  to_link_glob = "#{install_dir}/#{'*/' * i}*.symlink"
  ::Dir.glob(to_link_glob).map do |f|
    link_name = ::File.basename(f, '.symlink')
    link_path = f.sub("#{install_dir}/", '').sub("#{link_name}.symlink", '')

    directory "#{home_dir}/#{link_path}" do
      recursive true
      owner node['dotfiles']['user']
      group group
    end

    # Intentionally letting this fail if a file already exists at the target
    # until there's a better way to deal
    link "#{home_dir}/#{link_path}.#{link_name}" do
      to f
      owner node['dotfiles']['user']
      group group
    end
  end
end
