module Oober
  module Extractor
    class Stix < Hashie::Dash

      property :data
      property :select,      default: '/'
      property :extractions, default: []
      property :defaults,    default: {}
      property :description, default: ""

      def xml
        @xml ||= Nokogiri::XML(data,nil,nil,parse_options)
      end

      def selected
        @selected ||= begin
          xml.xpath(self.select).to_a
        rescue Nokogiri::XML::XPath::SyntaxError => e
          []
        end
      end

      def parse_options
        @parse_options ||= Nokogiri::XML::ParseOptions::DEFAULT_XML|Nokogiri::XML::ParseOptions::NOBLANKS
      end

      def extract
        selected.map {|node| extract_selection(node)}
      end

      def extract_selection(node)
        mapped_values = extractions.map {|extraction| extract_value(extraction.merge(node: node)) }
        Hash[*mapped_values.flatten].merge(defaults)
      end

      def extract_value(node: nil, origin: nil, target: nil)
          target_key = target.to_sym
          target_val = ''
          begin
            target_val = [*node.xpath(origin)].first.to_s.strip
          rescue Exception => e
            STDERR.puts "FAILED TO EXTRACT #{origin}"
            STDERR.puts e.backtrace
            STDERR.puts e
          end
          [target_key, target_val]
        end
      end
    end
  end
