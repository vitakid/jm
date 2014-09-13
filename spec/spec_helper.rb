require "jm"

Dir.glob(File.dirname(__FILE__) + "/support/**/*.rb").each do |path|
  require path
end

# Don't check the availability of locales in the test suite
I18n.enforce_available_locales = false
