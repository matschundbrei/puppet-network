#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::team::dynamic', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'team1:1' }
    let :params do {
      :ensure => 'blah'
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-team1:1')}.to raise_error(Puppet::PreformattedError)
    end
  end

  context 'required parameters' do
    let(:title) { 'team2' }
    let :params do {
      :ensure => 'up',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_team2 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-team2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-team2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-team2] with required contents' do
      verify_contents(catalogue, 'ifcfg-team2', [
        'DEVICE=team2',
        'BOOTPROTO=dhcp',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'DEVICETYPE=Team',
        'TEAM_CONFIG=\'{"runner":{"name":"activebackup"},"link_watch":{"name":"ethtool"}}\'',
        'NM_CONTROLLED=no',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('teamd') }
  end

  context 'optional parameters' do
    let(:title) { 'team2' }
    let :params do {
      :ensure       => 'down',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :team_config  => { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool' },
    },
      :defroute     => 'yes',
      :metric       => '10',
      :zone         => 'trusted',
    }
    end
    let :facts do {
      :osfamily         => 'RedHat',
      :operatingsystem        => 'RedHat',
      :operatingsystemrelease => '6.0',
      :macaddress_team2 => 'ff:aa:ff:aa:ff:aa',
    }
    end
    it { should contain_file('ifcfg-team2').with(
      :ensure => 'present',
      :mode   => '0644',
      :owner  => 'root',
      :group  => 'root',
      :path   => '/etc/sysconfig/network-scripts/ifcfg-team2',
      :notify => 'Service[network]'
    )}
    it 'should contain File[ifcfg-team2] with required contents' do
      verify_contents(catalogue, 'ifcfg-team2', [
        'DEVICE=team2',
        'BOOTPROTO=dhcp',
        'ONBOOT=no',
        'HOTPLUG=no',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'DEFROUTE=yes',
        'ZONE=trusted',
        'METRIC=10',
        'NM_CONTROLLED=no',
        'DEVICETYPE=Team',
        'TEAM_CONFIG=\'{"runner":{"name":"activebackup"},"link_watch":{"name":"ethtool"}}\'',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('teamd') }
  end

end
