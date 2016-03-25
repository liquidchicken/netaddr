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

    def allocate(bits, name = 'VPC')
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
        raise ArgumentError, "Subnet must be smaller than VPC"
      elsif bits > 28
        raise ArgumentError, "AWS does not support subnets smaller than /28"
      end

      if @left.nil?
        @left = Subnet.new(split_net[:left])
      end

      #return true if @left.allocate(bits, name)
      if cidr = @left.allocate(bits, name)
        return cidr
      end

      if @right.nil?
        @right = Subnet.new(split_net[:right])
      end

      #return true if @right.allocate(bits, name)
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
