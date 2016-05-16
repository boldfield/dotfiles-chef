require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe 'dotfiles::default' do
  let(:platform) { nil }
  let(:chef_run) do
    #runner.converge(described_recipe)
    ChefSpec::SoloRunner.new(platform) do |node|
      node.set['dotfiles']['user'] = 'foo'
    end.converge(described_recipe)
  end

  context 'Mac OS X platform' do
    before do
      allow(Chef::Recipe::Dotfiles).to receive(:evaluate_links).and_return(
        [
          ['.vimrc', '/Users/foo', '/Users/foo/.dotfiles/vimrc.symlink'],
          ['bar', '/Users/foo/.foo', '/Users/foo/.dotfiles/foo/bar.symlink'],
        ]
      )
      allow(Chef::Recipe::Dotfiles).to receive(:evaluate_directories).and_return(
        [['.baz', '/Users/foo/bar', '']]
      )
      count = 0
      allow(::Dir).to receive(:exist?) do
        count += 1
        if count == 1
          true
        else
          false
        end
      end
    end
    let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

    it 'checks out dotfiles repo' do
      expect(chef_run).to checkout_git('/Users/foo/.dotfiles')
    end

    it 'creates .vimrc symlink' do
      expect(chef_run).to create_link('/Users/foo/.vimrc')
    end

    it 'creates .foo directory' do
      expect(chef_run).to create_directory('/Users/foo/.foo')
    end

    it 'creates bar symlink' do
      expect(chef_run).to create_link('/Users/foo/.foo/bar')
    end

    it 'creates bar/.baz directory' do
      expect(chef_run).to create_directory('/Users/foo/bar/.baz')
    end
  end

  context 'Ubuntu 16.04 platform' do
    let(:platform) { { platform: 'ubuntu', version: '16.04' } }
    before do
      allow(Chef::Recipe::Dotfiles).to receive(:evaluate_links).and_return(
        [
          ['.vimrc', '/home/foo', '/home/foo/.dotfiles/vimrc.symlink'],
          ['bar', '/home/foo/.foo', '/home/foo/.dotfiles/foo/bar.symlink'],
        ]
      )
      allow(Chef::Recipe::Dotfiles).to receive(:evaluate_directories).and_return(
        [['.baz', '/home/foo/bar', '']]
      )
      count = 0
      allow(::Dir).to receive(:exist?) do
        count += 1
        if count == 1
          true
        else
          false
        end
      end
    end


    it 'checks out dotfiles repo' do
      expect(chef_run).to checkout_git('/home/foo/.dotfiles')
    end

    it 'creates .vimrc symlink' do
      expect(chef_run).to create_link('/home/foo/.vimrc')
    end

    it 'creates .foo directory' do
      expect(chef_run).to create_directory('/home/foo/.foo')
    end

    it 'creates .foo/bar symlink' do
      expect(chef_run).to create_link('/home/foo/.foo/bar')
    end

    it 'creates bar/.baz directory' do
      expect(chef_run).to create_directory('/home/foo/bar/.baz')
    end
  end
end
