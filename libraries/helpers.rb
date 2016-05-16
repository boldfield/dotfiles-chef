class Chef
  class Recipe
    class Dotfiles
      class << self
        def evaluate_links(home, base_dir)
          evaluate_targets(home, base_dir, 'symlink')
        end

        def evaluate_directories(home, base_dir)
          evaluate_targets(home, base_dir, 'mkdir')
        end

        private

        def evaluate_targets(home, base_dir, type)
          # Support nesting up to two dirs deep
          ret = []
          (0..2).each do |i|
            glob = "#{base_dir}/#{'*/' * i}*.#{type}"
            ::Dir.glob(glob).map {|f| ret << elements(home, base_dir, type, f) }
          end
          ret
        end

        def elements(home, base_dir, type, file)
          name = ::File.basename(file, ".#{type}")
          rel_path = file.sub("#{base_dir}/", '').sub("#{name}.#{type}", '')
          rel_path = rel_path.sub(/^dot\./, '.').gsub(/\.symlink/, '')
          path = if rel_path[/^root\./].nil?
                   "#{home}/#{rel_path}"
                 else
                   rel_path.sub(/^root\./, '/')
                 end.sub(/\/$/, '')
          [name.sub(/^dot\./, '.'), path, file]
        end
      end
    end  unless defined?(Chef::Recipe::Dotfiles)
  end
end
