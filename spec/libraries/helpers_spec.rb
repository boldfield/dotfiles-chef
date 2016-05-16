require_relative '../spec_helper'
require_relative '../../libraries/helpers'


describe 'Chef::Recipe::Dotfiles' do
  context 'Symlinks on Any Platform' do
    it 'correctly maps symlinks in home dir' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'symlink',
                                            '/home/foo/.dotfiles/bar.symlink')
      expect(n).to eq('bar')
      expect(p).to eq('/home/foo')
      expect(f).to eq('/home/foo/.dotfiles/bar.symlink')
    end

    it 'correctly maps dotted symlinks in home dir' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'symlink',
                                            '/home/foo/.dotfiles/dot.bar.symlink')
      expect(n).to eq('.bar')
      expect(p).to eq('/home/foo')
      expect(f).to eq('/home/foo/.dotfiles/dot.bar.symlink')
    end

    it 'correctly maps nexted symlinks in dotted parents' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'symlink',
                                            '/home/foo/.dotfiles/dot.bar/foo.symlink')
      expect(n).to eq('foo')
      expect(p).to eq('/home/foo/.bar')
      expect(f).to eq('/home/foo/.dotfiles/dot.bar/foo.symlink')
    end

    it 'correctly maps links branching off root' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'symlink',
                                            '/home/foo/.dotfiles/root.opt/foo/bar.symlink')
      expect(n).to eq('bar')
      expect(p).to eq('/opt/foo')
      expect(f).to eq('/home/foo/.dotfiles/root.opt/foo/bar.symlink')
    end
  end

  context 'Mkdirs on Any Platform' do
    it 'correctly maps mkdir in home dir' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'mkdir',
                                            '/home/foo/.dotfiles/bar.mkdir')
      expect(n).to eq('bar')
      expect(p).to eq('/home/foo')
      expect(f).to eq('/home/foo/.dotfiles/bar.mkdir')
    end

    it 'correctly maps mkdir in dotted parent' do
      n, p, f = Chef::Recipe::Dotfiles.send(:elements,
                                            '/home/foo',
                                            '/home/foo/.dotfiles',
                                            'mkdir',
                                            '/home/foo/.dotfiles/dot.bar/baz.mkdir')
      expect(n).to eq('baz')
      expect(p).to eq('/home/foo/.bar')
      expect(f).to eq('/home/foo/.dotfiles/dot.bar/baz.mkdir')
    end
  end
end
