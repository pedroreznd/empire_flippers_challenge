module EmpireFlippers
  class Client
    include HTTParty

    base_uri "https://api.empireflippers.com/api/v1"

    DEFAULT_HEADERS = {
      "Accept" => "application/json"
    }.freeze

    class Error < StandardError; end

    def self.call(**params)
      new.call(**params)
    end

    def call(page: nil, limit: nil, listing_status: nil)
      response = self.class.get(
        "/listings/list",
        headers: DEFAULT_HEADERS,
        query: build_query(page: page, limit: limit, listing_status: listing_status),
        timeout: 10
      )

      raise Error, "Empire Flippers API request failed with status #{response.code}" unless response.success?

      response.parsed_response
    end

    private

    def build_query(page:, limit:, listing_status:)
      {
        page: page,
        limit: limit,
        listing_status: listing_status
      }.compact
    end
  end
end
