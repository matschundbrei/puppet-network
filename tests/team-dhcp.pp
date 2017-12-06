include network

## bonded interface - dhcp
#network::bond::dynamic { 'bond2':
#  ensure       => 'up',
#  slaves       => [ 'eth4', 'eth7', ],
# #bonding_opts => 'mode=active-backup',
# #mtu          => '1500',
# #ethtool_opts => 'speed 100 duplex full autoneg off',
#}

# bonded master interface - dhcp
network::team::dynamic { 'team2':
  ensure       => 'up',
  mtu          => '9000',
  ethtool_opts => 'speed 1000 duplex full autoneg off',
  team_config  => {
    runner     => {
      name => 'lacp',
    },
    active     => true,
    fast_rate  => true,
    tx_hash    => [ 'eth', 'ipv4', 'ipv6' ],
    link_watch => {
      name     => 'ethtool',
    }
  },
}
