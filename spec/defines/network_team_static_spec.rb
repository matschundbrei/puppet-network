#!/usr/bin/env rspec

require 'spec_helper'

describe 'network::team::static', :type => 'define' do

  context 'incorrect value: ensure' do
    let(:title) { 'team1' }
    let :params do {
      :ensure    => 'blah',
      :ipaddress => '1.2.3.4',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-team1')}.to raise_error(Puppet::PreformattedError)
    end
  end

  context 'incorrect value: ipaddress' do
    let(:title) { 'team1' }
    let :params do {
      :ensure    => 'up',
      :ipaddress => 'notAnIP',
      :netmask   => '255.255.255.0',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-team1')}.to raise_error(Puppet::PreformattedError)
    end
  end

  context 'incorrect value: ipv6address' do
    let(:title) { 'team1' }
    let :params do {
      :ensure      => 'up',
      :ipaddress   => '1.2.3.4',
      :netmask     => '255.255.255.0',
      :ipv6address => 'notAnIP',
    }
    end
    it 'should fail' do
      expect {should contain_file('ifcfg-team1')}.to raise_error(Puppet::PreformattedError)
    end
  end

  context 'required parameters' do
    let(:title) { 'team0' }
    let :params do {
      :ensure      => 'up',
      :team_config => { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool' },
    },
      :ipaddress => '1.2.3.5',
      :netmask   => '255.255.255.0',
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
    it 'should contain File[ifcfg-team0] with required contents' do
      verify_contents(catalogue, 'ifcfg-team0', [
        'DEVICE=team0',
        'BOOTPROTO=none',
        'ONBOOT=yes',
        'HOTPLUG=yes',
        'IPADDR=1.2.3.5',
        'NETMASK=255.255.255.0',
        'PEERDNS=no',
        'NM_CONTROLLED=no',
        'DEVICETYPE=Team',
        'TEAM_CONFIG=\'{"runner":{"name":"activebackup"},"link_watch":{"name":"ethtool"}}\'',
      ])
    end
    it { should contain_service('network') }
    it { should contain_package('teamd') }
  end

  context 'optional parameters' do
    let(:title) { 'team0' }
    let :params do {
      :ensure       => 'down',
      :ipaddress    => '1.2.3.5',
      :netmask      => '255.255.255.0',
      :gateway      => '1.2.3.1',
      :mtu          => '9000',
      :ethtool_opts => 'speed 1000 duplex full autoneg off',
      :team_config  => { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool' },
    },
      :peerdns      => true,
      :dns1         => '3.4.5.6',
      :dns2         => '5.6.7.8',
      :ipv6init     => true,
      :ipv6peerdns  => true,
      :ipv6address  => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
      :ipv6gateway  => '123:4567:89ab:cdef:123:4567:89ab:1',
      :domain       => 'somedomain.com',
      :defroute     => 'yes',
      :metric       => '10',
      :zone         => 'trusted',
      :userctl      => true,
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
        'BOOTPROTO=none',
        'ONBOOT=no',
        'HOTPLUG=no',
        'IPADDR=1.2.3.5',
        'NETMASK=255.255.255.0',
        'GATEWAY=1.2.3.1',
        'MTU=9000',
        'ETHTOOL_OPTS="speed 1000 duplex full autoneg off"',
        'PEERDNS=yes',
        'DNS1=3.4.5.6',
        'DNS2=5.6.7.8',
        'DOMAIN="somedomain.com"',
        'USERCTL=yes',
        'IPV6INIT=yes',
        'IPV6ADDR=123:4567:89ab:cdef:123:4567:89ab:cdef/64',
        'IPV6_DEFAULTGW=123:4567:89ab:cdef:123:4567:89ab:1',
        'IPV6_PEERDNS=yes',
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
