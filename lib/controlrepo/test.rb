class Controlrepo
  class Test
    @@all =[]

    attr_accessor :nodes
    attr_accessor :classes
    
    # This can accept a bunch of stuff. It can accept nodes, classes or groups anywhere
    # it will then detect them and expand them out into their respective objects so that
    # we just end up with a list of nodes and classes
    def initialize(on_these,test_this)
      @nodes = []
      @classes = []

      # Get the nodes we are working on
      if Controlrepo::Group.find(on_these)
        @nodes << Controlrepo::Group.find(on_these).members
      elsif Controlrepo::Node.find(on_these)
        @nodes << Controlrepo::Node.find(on_these)
      else
        raise "#{on_these} was not found in the list of nodes or groups!"
      end

      @nodes.flatten!

      # Check that our nodes list contains only nodes
      raise "#{@nodes} contained a non-node object." unless @nodes.all? { |item| item.is_a?(Controlrepo::Node) }

      if test_this.is_a?(String)
        # If we have just given a string then grab all the classes it corresponds to
        if Controlrepo::Group.find(test_this)
          @classes << Controlrepo::Group.find(test_this).members
        elsif Controlrepo::Class.find(test_this)
          @classes << Controlrepo::Class.find(test_this)
        else
          raise "#{test_this} was not found in the list of classes or groups!"
        end
        @classes.flatten!
      elsif test_this.is_a?(Hash)
        # If it is a hash we need to get creative

        # Get all of the included classes and add them
        if Controlrepo::Group.find(test_this['include'])
          @classes << Controlrepo::Group.find(test_this['include']).members
        elsif Controlrepo::Class.find(test_this['include'])
          @classes << Controlrepo::Class.find(test_this['include'])
        else
          raise "#{test_this['include']} was not found in the list of classes or groups!"
        end
        @classes.flatten!

        # Then remove any excluded ones
        if Controlrepo::Group.find(test_this['exclude'])
          Controlrepo::Group.find(test_this['exclude']).members.each do |clarse|
            @classes.delete(clarse)
          end
        elsif Controlrepo::Class.find(test_this['exclude'])
          @classes.delete(Controlrepo::Class.find(test_this['exclude']))
        else
          raise "#{test_this['exclude']} was not found in the list of classes or groups!"
        end
      elsif test_this.is_a?(Controlrepo::Class)
        @classes << test_this
      end
    end

    def eql?(other)
      (@nodes.sort.eql?(other.nodes.sort)) and (@classes.sort.eql?(other.classes.sort))
    end

    def self.deduplicate(tests)
      # This should take an array of tests and remove any duplicates from them
      
      # this will be an array of arrays, or maybe hashes
      combinations = []
      tests.each do |test|
        test.nodes.each do |node|
          test.classes.each do |cls|
            combo = {node => cls}
            combinations << combo unless combinations.member?(combo)
          end
        end
      end
      new_tests = []
      combinations.each do |combo|
        combo.each do |node,cls|
          new_tests << Controlrepo::Test.new(node,cls)
        end
      end
      binding.pry
    end

    def self.all
      @@all
    end
  end
end
