FactoryBot.define do
  factory :listing do
    sequence(:listing_number) { |n| "L#{n}" }
    listing_price { 9.99 }
    summary { "Content site with stable traffic" }
    status { "For Sale" }
    raw_payload { {} }
    hubspot_deal_id { nil }
    last_synced_at { nil }
  end
end
