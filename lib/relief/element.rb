module Relief
  class Element
    attr_reader :name, :options, :children

    def initialize(name, options, &block)
      @name = name
      @options = options
      @children = {}

      instance_eval(&block) if block_given?
    end

    def parse(document)
      @children.inject({}) do |values, child|
        name, element = child

        values[name] = begin
          target = (document / element.xpath)

          parse_node = lambda { |target|
            element.children.any? ? element.parse(target) : target.to_s
          }

          if element.options[:collection]
            target.collect { |child| parse_node.call(child) }
          else
            parse_node.call(target)
          end
        end

        values
      end
    end

    def element(name, options={}, &block)
      options[:xpath] ||= name if name =~ %r([/.])
      name = options[:as].to_sym if options.has_key?(:as)
      @children[name] ||= self.class.new(name, options, &block)
    end

    def elements(name, options={}, &block)
      element(name, options.merge(:collection => true), &block)
    end

    def attribute(name, options={}, &block)
      element(name, options.merge(:attribute => true), &block)
    end

    def xpath
      if options.has_key?(:xpath)
        options[:xpath]
      elsif @children.empty?
        attribute = @options[:attribute]
        attribute = name if attribute == true
        !attribute ? "#{name}/text()" : "@#{attribute}"
      else
        name.to_s
      end
    end
  end
end
