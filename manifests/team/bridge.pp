# == Definition: network::bond::bridge
#
# Creates a bonded, bridge interface and enables the bonding driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $bridge       - required
#   $mtu          - optional
#   $ethtool_opts - optional
#   $team_config  - required - hash
#   $restart      - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::team::bridge { 'team2':
#     ensure => 'up',
#     bridge => 'br0',
#   }
#
# === Authors:
#
# David Cote
# Mike Arnold <mike@razorsedge.org>
# Jan Kapellen <jan.kapellen@gigacodes.de>
#
# === Copyright:
#
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
# Copyright (c) 2017 Jan Kapellen
define network::team::bridge (
  Enum['up', 'down'] $ensure,
  String            $bridge,
  Optional[String]  $mtu          = undef,
  Optional[String]  $ethtool_opts = undef,
  Hash              $team_config  = { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool' },
  },
  Optional[Boolean] $restart      = true,
) {
  ensure_packages(['teamd'])

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => '',
    bootproto    => 'none',
    ipv6address  => '',
    ipv6gateway  => '',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    team_config  => $team_config,
    bridge       => $bridge,
    restart      => $restart,
  }
} # define network::team::bridge
