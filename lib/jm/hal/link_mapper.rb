require "addressable/template"

module JM
  module HAL
    # Map parameter hashes onto URI via URI templates
    class LinkMapper < Mapper
      def initialize(uri_template)
        @uri_template = Addressable::Template.new(uri_template)
      end

      def read(link)
        href = link["href"]
        params = @uri_template.extract(href)

        if params
          Success.new(params)
        else
          error = Errors::InvalidLinkError.new([], @uri_template.pattern, href)
          Failure.new(error)
        end
      end

      def write(params)
        href = @uri_template.expand(params).to_s

        Success.new("href" => href)
      end
    end
  end
end
