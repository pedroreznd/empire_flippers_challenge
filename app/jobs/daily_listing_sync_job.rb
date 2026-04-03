class DailyListingSyncJob < ApplicationJob
  queue_as :default

  def perform
    Listings::Importer.call
    Hubspot::DealSyncService.call
  end
end
