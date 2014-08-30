module JM
  module Errors
    # The link did not match the pattern
    class InvalidLinkError < Error
      def initialize(template, link)
        super(:invalid_link, template: template, link: link)
      end
    end
  end
end
