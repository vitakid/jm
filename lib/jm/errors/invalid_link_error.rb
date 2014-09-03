module JM
  module Errors
    # The link did not match the pattern
    class InvalidLinkError < Error
      def initialize(path, template, link)
        super(path, :invalid_link, template: template, link: link)
      end
    end
  end
end
