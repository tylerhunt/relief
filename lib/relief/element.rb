module Relief
  class Element
    attr_reader :name, :options, :children

    def initialize(name, options, &block)
      @name = name
      @options = options
      @children = []

      instance_eval(&block) if block_given?
    end

    def parse(document)
      @children.inject({}) do |values, element|
        key = element.options[:as] || element.name

        values[key] = begin
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
      @children << self.class.new(name, options, &block)
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
      elsif @children.any?
        name.to_s
      else
        attribute = @options[:attribute]
        attribute = name if attribute == true
        !attribute ? "#{name}/text()" : "@#{attribute}"
      end
    end
  end
end
