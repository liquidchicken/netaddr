#!/usr/bin/env ruby

require_relative '../lib/netaddr'

net = NetAddr::Subnet.new('10.11.0.0/23')
net.reserve('10.11.0.0/24', 'lower')
net.reserve('10.11.1.0/24', 'upper')
net.reserve('10.11.1.0/24', 'boom')

#net.allocate(15, 'fifteen')

net.dump

