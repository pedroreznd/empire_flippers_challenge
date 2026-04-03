module Hubspot
  class DealSyncService
    def self.call(listing: nil)
      new(listing: listing).call
    end

    def initialize(listing: nil, client: ::Hubspot::Client.new(access_token: ENV.fetch("HUBSPOT_ACCESS_TOKEN")))
      @listing = listing
      @client = client
    end

    def call
      listings.find_each do |record|
        sync_listing(record)
      end
    end

    private

    attr_reader :listing, :client

    def listings
      return ::Listing.where(id: listing.id) if listing.present?

      ::Listing.where(status: "For Sale")
    end

    def sync_listing(record)
      return record if record.hubspot_deal_id.present?

      deal_id = find_existing_deal_id(record) || create_deal(record).id
      record.update!(hubspot_deal_id: deal_id)

      record
    end

    def find_existing_deal_id(record)
      search_results(record).results.first&.id
    end

    def search_results(record)
      client.crm.deals.search_api.do_search(body: search_body(record))
    end

    def search_body(record)
      {
        filterGroups: [
          {
            filters: [
              {
                propertyName: "dealname",
                operator: "EQ",
                value: deal_name(record)
              }
            ]
          }
        ],
        limit: 1
      }
    end

    def create_deal(record)
      client.crm.deals.basic_api.create(body: create_body(record))
    end

    def create_body(record)
      {
        properties: {
          dealname: deal_name(record),
          amount: record.listing_price,
          closedate: closedate_in_milliseconds,
          description: record.summary
        }
      }
    end

    def closedate_in_milliseconds
      30.days.from_now.to_i * 1000
    end

    def deal_name(record = listing)
      "Listing #{record.listing_number}"
    end
  end
end
