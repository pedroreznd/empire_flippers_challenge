require "rails_helper"

RSpec.describe Listings::Importer, type: :service do
  subject(:importer) { described_class.new(client: client) }

  let(:client) { instance_double(EmpireFlippers::Client, call: response) }
  let(:response) do
    {
      "data" => {
        "listings" => listings_payload
      }
    }
  end

  describe "#call" do
    context "when the client returns listings" do
      let(:listings_payload) do
        [
          {
            "listing_number" => "12345",
            "listing_price" => "150000",
            "summary" => "Newsletter business",
            "listing_status" => "For Sale",
            "extra_field" => "kept in payload"
          }
        ]
      end

      it "imports listings from the client response into the database" do
        expect { importer.call }.to change(Listing, :count).by(1)
      end

      it "maps the supported listing fields" do
        importer.call

        listing = Listing.find_by!(listing_number: "12345")

        expect(listing.listing_price).to eq(BigDecimal("150000"))
        expect(listing.summary).to eq("Newsletter business")
        expect(listing.status).to eq("For Sale")
        expect(listing.raw_payload).to eq(listings_payload.first)
      end

      it "does not create duplicates when the same listing is imported twice" do
        importer.call

        expect { importer.call }.not_to change(Listing, :count)
      end
    end

    context "when a listing is missing listing_number" do
      let(:listings_payload) do
        [
          {
            "listing_number" => nil,
            "listing_price" => "99000",
            "summary" => "Missing number",
            "listing_status" => "For Sale"
          }
        ]
      end

      it "ignores the entry" do
        expect { importer.call }.not_to change(Listing, :count)
      end
    end
  end
end
