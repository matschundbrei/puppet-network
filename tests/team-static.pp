include network

## bonded interface - static
#network::bond::static { 'bond0':
#  ensure       => 'up',
#  ipaddress    => '1.2.3.5',
#  netmask      => '255.255.255.0',
#  gateway      => '1.2.3.1',
#  slaves       => [ 'eth1', 'eth2', ],
#  bonding_opts => 'mode=active-backup',
#  mtu          => '8000',
#  ethtool_opts => 'speed 100 duplex full autoneg off',
#}

# teamd master interface - static
network::team::static { 'team0':
  ensure      => 'up',
  ipaddress   => '1.2.3.5',
  netmask     => '255.255.255.0',
  gateway     => '1.2.3.1',
  ipv6init    => true,
  ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef/64',
  ipv6gateway => '123:4567:89ab:cdef:123:4567:89ab:1',
  mtu         => '9000',
  team_config => {
    runner     => {
      name => 'lacp',
    },
    active     => true,
    fast_rate  => true,
    tx_hash    => [ 'eth', 'ipv4', 'ipv6' ],
    link_watch => {
      name => 'ethtool',
    }
  },
}

# bonded slave interface - static
network::team::slave { 'eth1':
  macaddress       => $::macaddress_eth1,
  ethtool_opts     => 'speed 1000 duplex full autoneg off',
  master           => 'team0',
  team_port_config => {
    prio => 100,
  }
}

# bonded slave interface - static
network::team::slave { 'eth3':
  macaddress       => $::macaddress_eth3,
  ethtool_opts     => 'speed 100 duplex half autoneg off',
  master           => 'team0',
  team_port_config => {
    prio => 100,
  }
}
