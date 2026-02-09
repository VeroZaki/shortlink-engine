require_relative "boot"

require "rails"
require "active_model/railtie"
require "action_controller/railtie"
require "action_dispatch/railtie"
require "active_record/railtie"

module ShortlinkEngine
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.autoload_paths << Rails.root.join("lib")
    config.root = __dir__.join("..")
  end
end
