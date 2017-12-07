#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::team::bridge', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'team1' }
    let :params do {
      :ensure => 'blah',
      :bridge => 'br0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-team1')}.to raise_error(Puppet::PreformattedError)
    end
  end

  context 'required parameters' do
    let(:title) { 'team0' }
    let :params do {
      :ensure => 'up',
      :bridge => 'br0',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_team0 => 'fe:fe:fe:aa:aa:aa',
    }
    end
    it { should contain_file('ifcfg-team0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-team0',
      :notify => 'Service[network]'
    )}
    it { pp catalogue.resources }
    it 'should contain File[ifcfg-team0] with required contents' do
      verify_contents(catalogue, 'ifcfg-team0', [
        'DEVICE=team0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'DEVICETYPE=Team',
        'TEAM_CONFIG=\'{"runner":{"name":"activebackup"},"link_watch":{"name":"ethtool"}}\'',
        'PEERDNS=no',
        'BRIDGE=br0',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('teamd') }
  end

  context 'optional parameters' do
    let(:title) { 'team0' }
    let :params do {
      :ensure       => 'down',
      :bridge       => 'br6',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
    }
    end
    let :facts do {
      :osfamily               => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0'
    }
    end
    it { should contain_file('ifcfg-team0').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-team0',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-team0] with required contents' do
      verify_contents(catalogue, 'ifcfg-team0', [
        'DEVICE=team0',
        'DEVICETYPE=Team',
        'TEAM_CONFIG=\'{"runner":{"name":"activebackup"},"link_watch":{"name":"ethtool"}}\'',
        'BOOTPROTO=none',
        'ONBOOT=no',
        'HOTPLUG=no',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'BRIDGE=br6',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('teamd') }
  end

end
