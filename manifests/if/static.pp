# == Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# === Parameters:
#
#   $ensure         - required - up|down
#   $ipaddress      - optional
#   $netmask        - optional
#   $gateway        - optional
#   $ipv6address    - optional
#   $ipv6init       - optional - defaults to false
#   $ipv6gateway    - optional
#   $manage_hwaddr  - optional - defaults to true
#   $macaddress     - optional - defaults to macaddress_$title
#   $ipv6autoconf   - optional - defaults to false
#   $userctl        - optional - defaults to false
#   $mtu            - optional
#   $ethtool_opts   - optional
#   $peerdns        - optional
#   $ipv6peerdns    - optional - defaults to false
#   $dns1           - optional
#   $dns2           - optional
#   $domain         - optional
#   $scope          - optional
#   $flush          - optional
#   $zone           - optional
#   $metric         - optional
#   $defroute       - optional
#   $restart        - optional - defaults to true
#   $arpcheck       - optional - defaults to true
#   $vlan           - optional - yes|no defaults to no
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::if::static { 'eth0':
#     ensure      => 'up',
#     ipaddress   => '10.21.30.248',
#     netmask     => '255.255.255.128',
#     macaddress  => $::macaddress_eth0,
#     domain      => 'is.domain.com domain.com',
#     ipv6init    => true,
#     ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef',
#     ipv6gateway => '123:4567:89ab:cdef:123:4567:89ab:1',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::if::static (
    Enum['up','down']                                                 $ensure,
  Optional[Stdlib::Compat::Ipv4]                                      $ipaddress    = undef,
  Optional[Stdlib::Compat::Ipv4]                                      $netmask      = undef,
  Optional[Stdlib::Compat::Ipv4]                                      $gateway      = undef,
  Optional[Stdlib::MAC]                                               $macaddress   = undef,
  Optional[String]                                                    $mtu          = undef,
  Optional[String]                                                    $ethtool_opts = undef,
  Optional[Boolean]                                                   $peerdns      = false,
  Optional[Boolean]                                                   $ipv6init     = false,
  Optional[Variant[Network::IpV6cidr, Array[Network::IpV6cidr]]]$ipv6address  = undef,
  Optional[Network::IpV6cidr]                                      $ipv6gateway  = undef,
  Optional[Boolean]                                                   $ipv6peerdns  = false,
  Optional[Stdlib::Compat::Ipv4]                                      $dns1         = undef,
  Optional[Stdlib::Compat::Ipv4]                                      $dns2         = undef,
  Optional[String]                                                    $domain       = undef,
  Optional[String]                                                    $zone         = undef,
  Optional[String]                                                    $defroute     = undef,
  Optional[String]                                                    $metric       = undef,
  Optional[Boolean]                                                   $restart      = true,
  Optional[Boolean]                                                   $userctl      = undef,
  Optional[Enum['yes','no']]                                          $vlan         = undef,
  Optional[String]                                                    $linkdelay    = undef,
  Optional[String]                                                    $scope        = undef,
  Optional[Boolean]                                                   $flush        = false,
  Optional[Boolean]                                                   $arpcheck     = true,
  Optional[Boolean]                                                   $ipv6autoconf = true,
  Optional[Boolean]                                                   $manage_hwaddr= true,
) {
  if is_array($ipv6address) {
    if size($ipv6address) > 0 {
      $primary_ipv6address = $ipv6address[0]
      $secondary_ipv6addresses = delete_at($ipv6address, 0)
    }
  } elsif $ipv6address {
    $primary_ipv6address = $ipv6address
    $secondary_ipv6addresses = undef
  } else {
    $primary_ipv6address = undef
    $secondary_ipv6addresses = undef
  }

  if $macaddress {
    $macaddy = $macaddress
  } else{
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $title_clean = regsubst($title,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${title_clean}")
  }

  network_if_base { $title:
    ensure          => $ensure,
    ipv6init        => $ipv6init,
    ipaddress       => $ipaddress,
    ipv6address     => $primary_ipv6address,
    netmask         => $netmask,
    gateway         => $gateway,
    ipv6gateway     => $ipv6gateway,
    ipv6autoconf    => $ipv6autoconf,
    ipv6secondaries => $secondary_ipv6addresses,
    macaddress      => $macaddy,
    manage_hwaddr   => $manage_hwaddr,
    bootproto       => 'none',
    userctl         => $userctl,
    mtu             => $mtu,
    ethtool_opts    => $ethtool_opts,
    peerdns         => $peerdns,
    ipv6peerdns     => $ipv6peerdns,
    dns1            => $dns1,
    dns2            => $dns2,
    domain          => $domain,
    linkdelay       => $linkdelay,
    scope           => $scope,
    flush           => $flush,
    zone            => $zone,
    defroute        => $defroute,
    metric          => $metric,
    restart         => $restart,
    arpcheck        => $arpcheck,
    vlan            => $vlan,
  }
} # define network::if::static
