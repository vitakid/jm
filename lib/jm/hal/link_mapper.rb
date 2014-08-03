require "addressable/template"

module JM
  module HAL
    class LinkMapper < Mapper
      def initialize(uri_template, params_mapper)
        @uri_template = Addressable::Template.new(uri_template)
        @params_mapper = params_mapper
      end

      def read(link)
        params = @uri_template.extract(link[:href])

        @params_mapper.read(params)
      end

      def write(object)
        params = @params_mapper.write(object)
        href = @uri_template.expand(params).to_s

        { href: href }
      end
    end
  end
end
