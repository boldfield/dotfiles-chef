#
# Cookbook Name:: dotfiles
# Recipe:: default
#
# Copyright (C) 2016 Brian Oldfield
#
#

# Move into library
def evaluate_targets(home, base_dir, type)
  # Support nesting up to two dirs deep
  ret = []
  (0..2).each do |i|
    glob = "#{base_dir}/#{'*/' * i}*.#{type}"
    ::Dir.glob(glob).map do |f|
      name = ::File.basename(f, ".#{type}")
      rel_path = f.sub("#{base_dir}/", '').sub("#{name}.#{type}", '')
      ret << [name, rel_path, f]
    end
    ret
  end
end

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

evaluate_targets(home_dir, install_dir, 'symlink').each do |name, rel_path, target|
  # Create parent directory for links if required
  if rel_path != '/'
    directory "#{home_dir}/#{rel_path}" do
      recursive true
      owner node['dotfiles']['user']
      group group
    end
  end

  # Intentionally letting this fail if a file already exists at the target
  # until there's a better way to deal
  link "#{home_dir}/#{rel_path}.#{name}" do
    to target
    owner node['dotfiles']['user']
    group group
  end
end

evaluate_targets(home_dir, install_dir, 'mkdir').each do |name, rel_path, _|
  directory "#{home_dir}/#{rel_path}#{name}" do
    recursive true
    owner node['dotfiles']['user']
    group group
  end
end
