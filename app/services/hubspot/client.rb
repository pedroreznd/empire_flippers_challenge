require "hubspot-api-client"

module Hubspot
  module ClientFactory
    module_function

    def call
      ::Hubspot::Client.new(access_token: ENV.fetch("HUBSPOT_ACCESS_TOKEN"))
    end
  end
end
