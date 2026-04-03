require "rails_helper"

RSpec.describe Hubspot::DealSyncService, type: :service do
  subject(:service) { described_class.new(listing: listing, client: client) }

  let(:listing) do
    create(
      :listing,
      listing_number: "12345",
      listing_price: 150_000,
      summary: "Content business with recurring revenue",
      status: "For Sale",
      hubspot_deal_id: nil
    )
  end
  let(:client) { double("Hubspot client", crm: crm) }
  let(:crm) { double("Hubspot CRM", deals: deals) }
  let(:deals) { double("Hubspot deals", search_api: search_api, basic_api: basic_api) }
  let(:search_api) { double("Hubspot search api") }
  let(:basic_api) { double("Hubspot basic api") }
  let(:search_results) { double("Hubspot search results", results: []) }

  before do
    allow(search_api).to receive(:do_search).and_return(search_results)
    allow(basic_api).to receive(:create).and_return(double("Hubspot deal", id: "deal-123"))
  end

  describe "#call" do
    it "creates a HubSpot deal for a listing with status For Sale" do
      service.call

      expect(search_api).to have_received(:do_search).with(
        body: hash_including(
          filterGroups: [
            {
              filters: [
                {
                  propertyName: "dealname",
                  operator: "EQ",
                  value: "Listing 12345"
                }
              ]
            }
          ],
          limit: 1
        )
      )
      expect(basic_api).to have_received(:create).with(
        body: hash_including(
          properties: hash_including(
            dealname: "Listing 12345",
            amount: 150_000,
            description: "Content business with recurring revenue"
          )
        )
      )
    end

    it "saves the returned HubSpot id into listing.hubspot_deal_id" do
      service.call

      expect(listing.reload.hubspot_deal_id).to eq("deal-123")
    end

    it "skips creating a new deal when hubspot_deal_id is already present" do
      listing.update!(hubspot_deal_id: "existing-local-id")

      service.call

      expect(search_api).not_to have_received(:do_search)
      expect(basic_api).not_to have_received(:create)
    end

    it "stores an existing HubSpot id when search finds a matching deal" do
      allow(search_api).to receive(:do_search).and_return(
        double("Hubspot search results", results: [ double("Hubspot deal", id: "existing-deal-id") ])
      )

      service.call

      expect(basic_api).not_to have_received(:create)
      expect(listing.reload.hubspot_deal_id).to eq("existing-deal-id")
    end
  end

  describe ".call" do
    let!(:for_sale_listing) do
      create(:listing, listing_number: "10001", status: "For Sale", hubspot_deal_id: nil)
    end
    let!(:sold_listing) do
      create(:listing, listing_number: "10002", status: "Sold", hubspot_deal_id: nil)
    end

    before do
      allow(::Hubspot::Client).to receive(:new).and_return(client)
    end

    it "only syncs local listings with status For Sale when no listing is passed" do
      described_class.call

      expect(for_sale_listing.reload.hubspot_deal_id).to eq("deal-123")
      expect(sold_listing.reload.hubspot_deal_id).to be_nil
      expect(search_api).to have_received(:do_search).once
      expect(basic_api).to have_received(:create).once
    end
  end
end
