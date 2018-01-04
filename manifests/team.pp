# == Definition: network::bond
#
# Creates a bonded interface with no IP information and enables the
# bonding driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $mtu          - optional
#   $ethtool_opts - optional
#   $team_config  - required - hash
#   $zone         - optional
#   $restart      - optional - defaults to true
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::team { 'team2':
#     ensure      => 'up',
#     team_config => { runner => { name => 'activebackup' }, link_watch => { name => 'ethtool' }, },
#   }
#
# === Authors:
#
# Jason Vervlied <jvervlied@3cinteractive.com>
# Jan Kapellen <jan.kapellen@gigacodes.de>
#
# === Copyright:
#
# Copyright (C) 2015 Jason Vervlied, unless otherwise noted.
# Copyright (C) 2017 Jan Kapellen
#
define network::team (
  Enum['up', 'down']  $ensure,
  Optional[String]    $mtu          = undef,
  Optional[String]    $ethtool_opts = undef,
  Hash                $team_config  = { 'runner' => { 'name' => 'activebackup' }, 'link_watch' => { 'name' => 'ethtool'
  }, },
  Optional[String]    $zone         = undef,
  Optional[Boolean]   $restart      = true,
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
    zone         => $zone,
    restart      => $restart,
  }
} # define network::team
