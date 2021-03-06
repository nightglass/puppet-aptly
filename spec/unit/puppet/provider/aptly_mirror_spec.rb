require 'spec_helper'
require 'puppet/type/aptly_mirror'

describe Puppet::Type.type(:aptly_mirror).provider(:cli) do
  let(:resource) do
    Puppet::Type.type(:aptly_mirror).new(
      :name         => 'debian-main',
      :ensure       => 'present',
      :location     => 'http://ftp.us.debian.org',
      :distribution => 'test',
    )
  end

  let(:provider) do
    described_class.new(resource)
  end

  [:create, :destroy, :exists? ].each do |method|
    it "should have a(n) #{method}" do
      expect(provider).to respond_to(method)
    end
  end

  describe '#create' do
    it 'should create and update the mirror' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'create',
        arguments: [ 'debian-main', 'http://ftp.us.debian.org', 'test', 'undef' ],
        flags: {
        'architectures' => 'undef',
        'with-sources'  => false,
        'with-udebs'    => false,
        }
      )
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'update',
        arguments: [ 'debian-main' ]
      )
      provider.create
    end

    it 'should not update when update is false' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'create',
        arguments: [ 'debian-main', 'http://ftp.us.debian.org', 'test', 'undef' ],
        flags: {
        'architectures' => 'undef',
        'with-sources'  => false,
        'with-udebs'    => false,
        }
      )
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'update',
        arguments: [ 'debian-main' ]
      ).never
      resource2 = Puppet::Type.type(:aptly_mirror).new(
        :name         => 'debian-main',
        :ensure       => 'present',
        :location     => 'http://ftp.us.debian.org',
        :distribution => 'test',
        :update       => :false,
      )
      described_class.new(resource2).create
    end
  end

  describe '#destroy' do
    it 'should drop the mirror' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'drop',
        arguments: ['debian-main'],
        flags: { 'force' => '' },
      )
      provider.destroy
    end
  end

  describe '#exists?' do
    it 'should check the mirrors list' do
      Puppet_X::Aptly::Cli.expects(:execute).with(
        object: :mirror,
        action: 'show',
        arguments: ['debian-main'],
        exceptions: false,
      )
      provider.exists?
    end
  end

end
