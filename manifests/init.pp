# == Class: network
#
# This module manages Red Hat/Fedora network configuration.
#
# === Parameters:
#
# None
#
# === Actions:
#
# Defines the network service so that other resources can notify it to restart.
#
# === Sample Usage:
#
#   include '::network'
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
class network {
  # Only run on RedHat derived systems.
  case $::osfamily {
    'RedHat': { }
    default: {
      fail('This network module only supports RedHat-based systems.')
    }
  }

  service { 'network':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    provider   => 'redhat',
  }
} # class network

# == Definition: network_if_base
#
# This definition is private, i.e. it is not intended to be called directly
# by users.  It can be used to write out the following device files:
#  /etc/sysconfig/networking-scripts/ifcfg-eth
#  /etc/sysconfig/networking-scripts/ifcfg-eth:alias
#  /etc/sysconfig/networking-scripts/ifcfg-bond(master)
#
# === Parameters:
#
#   $ensure          - required - up|down
#   $ipaddress       - optional
#   $netmask         - optional
#   $macaddress      - required
#   $manage_hwaddr   - optional - defaults to true
#   $gateway         - optional
#   $noaliasrouting  - optional - defaults to false
#   $bootproto       - optional
#   $userctl         - optional - defaults to false
#   $mtu             - optional
#   $dhcp_hostname   - optional
#   $ethtool_opts    - optional
#   $bonding_opts    - optional
#   $isalias         - optional
#   $peerdns         - optional
#   $dns1            - optional
#   $dns2            - optional
#   $domain          - optional
#   $bridge          - optional
#   $scope           - optional
#   $linkdelay       - optional
#   $check_link_down - optional
#   $flush           - optional
#   $zone            - optional
#   $metric          - optional
#   $defroute        - optional
#   $promisc         - optional - defaults to false
#   $restart         - optional - defaults to true
#   $arpcheck        - optional - defaults to true
#   $vlan            - optional - defaults to 'no'
#
# === Actions:
#
# Performs 'service network restart' after any changes to the ifcfg file and $restart parameter is 'true'.
#
# === TODO:
#
#   HOTPLUG=yes|no
#   WINDOW=
#   SCOPE=
#   SRCADDR=
#   NOZEROCONF=yes
#   PERSISTENT_DHCLIENT=yes|no|1|0
#   DHCPRELEASE=yes|no|1|0
#   DHCLIENT_IGNORE_GATEWAY=yes|no|1|0
#   REORDER_HDR=yes|no
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network_if_base (
  Enum['up','down']                                               $ensure,
  Optional[Variant[Stdlib::MAC, String]]                          $macaddress,
  Optional[Variant[Enum[''], Stdlib::Compat::Ipv4]]               $ipaddress       = undef,
  Optional[Variant[Enum[''], Stdlib::Compat::Ipv4]]               $netmask         = undef,
  Optional[Boolean]                                               $manage_hwaddr   = true,
  Optional[Variant[Enum[''], Stdlib::Compat::Ipv4]]               $gateway         = undef,
  Optional[Boolean]                                               $noaliasrouting  = false,
  Optional[Variant[Enum[''], Network::IpV6cidr]]                  $ipv6address     = undef,
  Optional[Variant[Enum[''], Network::IpV6cidr]]                  $ipv6gateway     = undef,
  Optional[Boolean]                                               $ipv6init        = false,
  Optional[Boolean]                                               $ipv6autoconf    = false,
  Optional[Variant[Network::IpV6cidr, Array[Network::IpV6cidr]]]  $ipv6secondaries = undef,
  Optional[String]                                                $bootproto       = 'none',
  Optional[Boolean]                                               $userctl         = false,
  Optional[String]                                                $mtu             = undef,
  Optional[String]                                                $dhcp_hostname   = undef,
  Optional[String]                                                $ethtool_opts    = undef,
  Optional[String]                                                $bonding_opts    = undef,
  Optional[Boolean]                                               $isalias         = false,
  Optional[Boolean]                                               $peerdns         = false,
  Optional[Boolean]                                               $ipv6peerdns     = false,
  Optional[String]                                                $dns1            = undef,
  Optional[String]                                                $dns2            = undef,
  Optional[String]                                                $domain          = undef,
  Optional[String]                                                $bridge          = undef,
  Optional[String]                                                $linkdelay       = undef,
  Optional[String]                                                $scope           = undef,
  Optional[Boolean]                                               $check_link_down = false,
  Optional[Boolean]                                               $flush           = false,
  Optional[Enum['yes','no']]                                      $defroute        = undef,
  Optional[String]                                                $zone            = undef,
  Optional[String]                                                $metric          = undef,
  Optional[Boolean]                                               $promisc         = false,
  Optional[Boolean]                                               $restart         = true,
  Optional[Boolean]                                               $arpcheck        = true,
  Optional[Enum['yes','no']]                                      $vlan            = undef,
) {
  include '::network'

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 {
    if !$dns1 {
      $dns1_real = $dns2
      $dns2_real = undef
    } else {
      $dns1_real = $dns1
      $dns2_real = $dns2
    }
  } else {
    $dns1_real = $dns1
    $dns2_real = $dns2
  }

  if $isalias {
    $onparent = $ensure ? {
      'up'    => 'yes',
      'down'  => 'no',
      default => undef,
    }
    $iftemplate = template('network/ifcfg-alias.erb')
  } else {
    $onboot = $ensure ? {
      'up'    => 'yes',
      'down'  => 'no',
      default => undef,
    }
    $iftemplate = template('network/ifcfg-eth.erb')
  }

  if $flush {
    exec { 'network-flush':
      user        => 'root',
      command     => "ip addr flush dev ${interface}",
      refreshonly => true,
      subscribe   => File["ifcfg-${interface}"],
      before      => Service['network'],
      path        => '/sbin:/usr/sbin',
    }
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => $iftemplate,
  }

  if $restart {
    File["ifcfg-${interface}"] {
      notify  => Service['network'],
    }
  }
} # define network_if_base
