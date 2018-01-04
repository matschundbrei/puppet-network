# == Definition: network::bond::dynamic
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.  bootp support is unknown for bonded interfaces.  Thus no bootp
# bond support in this module.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#   $zone         - optional
#   $metric       - optional
#   $defroute     - optional
#   $restart      - optional - defaults to true

#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bond::dynamic { 'bond2':
#     ensure => 'up',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
# Jan Kapellen <jan.kapellen@gigacodes.de>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
# Copyright (C) 2017 Jan Kapellen
#
define network::team::dynamic (
  Enum['up', 'down'] $ensure,
  Optional[String]  $mtu          = undef,
  Optional[String]  $ethtool_opts = undef,
  Hash              $team_config  = { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool' },
  },
  Optional[String]  $zone         = undef,
  Optional[String]  $defroute     = undef,
  Optional[String]  $metric       = undef,
  Optional[Boolean] $restart      = true,
) {
  ensure_packages(['teamd'])
  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => '',
    bootproto    => 'dhcp',
    ipv6address  => '',
    ipv6gateway  => '',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    team_config  => $team_config,
    zone         => $zone,
    defroute     => $defroute,
    metric       => $metric,
    restart      => $restart,
  }
} # define network::team::dynamic
