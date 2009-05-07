gem 'nokogiri', '~> 1.2.3'
require 'nokogiri'

module Relief
  class Parser
    attr_reader :root

    def initialize(name, options={}, &block)
      @root = Element.new(name, options, &block)
    end

    def parse(document)
      unless document.is_a?(Nokogiri::XML::NodeSet)
        document = Nokogiri::XML(document)
      end

      @root.parse(document)
    end
  end
end
