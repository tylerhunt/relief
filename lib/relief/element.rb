module Relief
  class Element
    attr_reader :name, :options, :children

    def initialize(name=nil, options={}, &block)
      @name = name
      @options = options
      @children = []

      instance_eval(&block) if block_given?
    end

    def parse(document)
      @children.inject({}) do |values, element|
        key = element.options[:as] || element.name
        type = element.options[:type]

        values[key] = begin
          target = (document / element.xpath)

          parse_node = lambda { |target|
            if element.children.any?
              element.parse(target)
            else
              value = target.to_s

              if type.nil? then value
              elsif value.empty? then nil
              elsif type == Integer then value.to_i
              elsif type == Float then value.to_f
              elsif type == Date then Date.parse(value)
              elsif type == DateTime then DateTime.parse(value)
              elsif type.is_a?(Parser) then type.parse(document)
              else value
              end
            end
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
