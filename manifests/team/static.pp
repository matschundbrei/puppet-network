# == Definition: network::bond::static
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - optional
#   $netmask      - optional
#   $gateway      - optional
#   $mtu          - optional
#   $ethtool_opts - optional
#   $team_config  - required - hash
#   $zone         - optional
#   $defroute     - optional
#   $restart      - optional - defaults to true
#   $metric       - optional
#   $userctl      - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bond::static { 'bond0':
#     ensure       => 'up',
#     ipaddress    => '1.2.3.5',
#     netmask      => '255.255.255.0',
#     bonding_opts => 'mode=active-backup miimon=100',
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
define network::team::static (
  Enum['up','down']                $ensure,
  Optional[Stdlib::Compat::Ipv4]   $ipaddress    = undef,
  Optional[Stdlib::Compat::Ipv4]   $netmask      = undef,
  Optional[Stdlib::Compat::Ipv4]   $gateway      = undef,
  Optional[String]                 $mtu          = undef,
  Optional[String]                 $ethtool_opts = undef,
  Hash                             $team_config  = { runner => { name => 'activebackup' }, link_watch => { name => 'ethtool' }, },
  Optional[Boolean]                $peerdns      = false,
  Optional[Boolean]                $ipv6init     = false,
  Optional[Network::IpV6cidr]      $ipv6address  = undef,
  Optional[Network::IpV6cidr]      $ipv6gateway  = undef,
  Optional[Boolean]                $ipv6peerdns  = false,
  Optional[Stdlib::Compat::Ipv4]   $dns1         = undef,
  Optional[Stdlib::Compat::Ipv4]   $dns2         = undef,
  Optional[String]                 $domain       = undef,
  Optional[String]                 $zone         = undef,
  Optional[String]                 $defroute     = undef,
  Optional[String]                 $metric       = undef,
  Optional[Boolean]                $restart      = true,
  Optional[Boolean]                $userctl      = undef,
) {
  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => $ipaddress,
    netmask      => $netmask,
    gateway      => $gateway,
    macaddress   => '',
    bootproto    => 'none',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    team_config  => $team_config,
    peerdns      => $peerdns,
    ipv6init     => $ipv6init,
    ipv6address  => $ipv6address,
    ipv6peerdns  => $ipv6peerdns,
    ipv6gateway  => $ipv6gateway,
    dns1         => $dns1,
    dns2         => $dns2,
    domain       => $domain,
    zone         => $zone,
    defroute     => $defroute,
    metric       => $metric,
    restart      => $restart,
    userctl      => $userctl,
  }

} # define network::bond::static
