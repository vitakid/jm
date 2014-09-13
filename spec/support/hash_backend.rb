module I18n
  module Backend
    # A very simple backend for i18n similar to I18n::Backend::KeyValue
    #
    # This exists because it does not rely on active_support as compared to
    # KeyValue.
    class HashBackend
      include I18n::Backend::Base

      def initialize(translations = {})
        @translations = translations
      end

      def []=(key, translation)
        @translations[key] = translation
      end

      def lookup(locale, key, scope = [], options = {})
        @translations[key]
      end
    end
  end
end
