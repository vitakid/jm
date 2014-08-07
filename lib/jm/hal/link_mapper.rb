require "addressable/template"

module JM
  module HAL
    # Map parameter hashes onto URI via URI templates
    class LinkMapper < Mapper
      def initialize(uri_template)
        @uri_template = Addressable::Template.new(uri_template)
      end

      def read(link)
        @uri_template.extract(link["href"])
      end

      def write(params)
        href = @uri_template.expand(params).to_s

        { "href" => href }
      end
    end
  end
end
