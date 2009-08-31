gem 'nokogiri', '~> 1.3.3'
require 'nokogiri'

module Relief
  class Error < StandardError ; end
  class ParseError < Error ; end

  class Parser
    attr_reader :root

    def initialize(name=nil, options={}, &block)
      @root = Element.new(name, options, &block)
    end

    def parse(document)
      unless document.is_a?(Nokogiri::XML::NodeSet)
        document = Nokogiri::XML(document.to_s)
      end

      raise ParseError if document.root.nil?

      @root.parse(document)
    end
  end
end
