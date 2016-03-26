#!/usr/bin/env ruby

require_relative '../lib/netaddr'
require 'byebug'; byebug

net = NetAddr::Subnet.new('10.96.0.0/12')
net.allocate(16, 'qa')
net.allocate(19, 'unused1')
net.reserve('10.100.0.0/14', 'test_100_14')
net.allocate(15, 'fifteen')
net.allocate(16, 'sixteen')
net.allocate(17, 'seventeen')
net.reserve('10.111.0.0/16', 'test_111_16')
net.reserve('10.97.0.0/16', 'BOOM!!!')

net.dump

