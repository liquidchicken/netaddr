module NetAddr
  class Subnet
    def initialize(cidr, name = nil)
      if cidr.kind_of?(NetAddr::CIDR)
        @cidr = cidr
      else
        @cidr = NetAddr::CIDR.create(cidr)
      end
      @name = name unless name.nil?
      @bits = @cidr.bits
      @allocated = false
      @left = nil
      @right = nil
    end

    def allocated?
      @allocated
    end

    def reserve(cidr, name = 'GENERIC_NETWORK')
      if @cidr == cidr             # We found our subnet
        if @left.nil? and @right.nil? # there are no children
          @name = name
          @allocated = true
          return @cidr
        else                          # There are children, so go back up
          raise StandardError, "This subnet is already allocated #{cidr}."
        end
      elsif not @cidr.contains?(cidr)
        return false
      elsif allocated?                   # This subnet is taken
        return false
      end

      @left = Subnet.new(split_net[:left]) if @left.nil?
      if reservation = @left.reserve(cidr, name)
        return reservation
      end

      @right = Subnet.new(split_net[:right]) if @right.nil?
      if reservation = @right.reserve(cidr, name)
        return reservation
      end

      false
    end

    def allocate(bits, name = 'GENERIC_NETWORK')
      if allocated?                   # This subnet is taken
        return false
      elsif @bits == bits             # This subnet is the right size, and
        if @left.nil? and @right.nil? # there are no children
          @name = name
          @allocated = true
          return @cidr
        else                          # There are children, so go back up
          return false
        end
      elsif bits <= @bits
        raise ArgumentError, "Subnet must be smaller than parent"
      elsif bits > 30
        raise ArgumentError, "Subnets smaller than /30 are not viable."
      end

      @left = Subnet.new(split_net[:left]) if @left.nil?
      if cidr = @left.allocate(bits, name)
        return cidr
      end

      @right = Subnet.new(split_net[:right]) if @right.nil?
      if cidr = @right.allocate(bits, name)
        return cidr
      end

      false
    end

    def split_net
      left_subnet = "#{@cidr.network}/#{@bits + 1}"
      left_subnet_cidr = NetAddr::CIDR.create(left_subnet)
      {
        left: left_subnet_cidr,
        right: left_subnet_cidr.succ
      }
    end

    def to_h
      Hash[allocated.map{|subnet| [subnet[:name].to_s, subnet[:cidr].to_s] }]
    end

    def allocated
      allocated_nets = Array.new
      allocated_nets.push(@left.allocated) unless @left.nil?
      allocated_nets.push(@right.allocated) unless @right.nil?
      if allocated?
        allocated_nets.push(cidr: @cidr, name: @name)
      end
      allocated_nets.flatten
    end

    def dump(indent = '')
      if allocated?
        puts "#{indent}#{@cidr.to_s}: #{@name}"
      else
        puts "#{indent}#{@cidr.to_s}"
      end
      new_indent = "#{indent}  "
      @left.dump(new_indent) unless @left.nil?
      @right.dump(new_indent) unless @right.nil?
    end
  end
end
