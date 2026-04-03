module Listings
  class Importer
    # Usage:
    # Listings::Importer.call
    def self.call(**params)
      new(**params).call
    end

    def initialize(client: EmpireFlippers::Client.new, **params)
      @client = client
      @params = params
    end

    def call
      listings.map { |listing_payload| upsert_listing(listing_payload) }.compact
    end

    private

    attr_reader :client, :params

    def listings
      response = client.call(**params)
      response.dig("data", "listings") || []
    end

    def upsert_listing(listing_payload)
      listing_number = listing_payload["listing_number"]
      return if listing_number.blank?

      listing = ::Listing.find_or_initialize_by(listing_number: listing_number)
      listing.assign_attributes(
        listing_price: listing_payload["listing_price"],
        summary: listing_payload["summary"],
        status: listing_payload["listing_status"],
        raw_payload: listing_payload
      )
      listing.save!

      listing
    end
  end
end
