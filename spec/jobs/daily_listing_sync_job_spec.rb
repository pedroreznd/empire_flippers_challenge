require "rails_helper"

RSpec.describe DailyListingSyncJob, type: :job do
  describe "#perform" do
    it "invokes the listings importer and HubSpot deal sync services" do
      allow(Listings::Importer).to receive(:call)
      allow(Hubspot::DealSyncService).to receive(:call)

      described_class.perform_now

      expect(Listings::Importer).to have_received(:call)
      expect(Hubspot::DealSyncService).to have_received(:call)
    end
  end
end
