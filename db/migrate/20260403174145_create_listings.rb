class CreateListings < ActiveRecord::Migration[7.2]
  def change
    create_table :listings do |t|
      t.string :listing_number
      t.decimal :listing_price
      t.text :summary
      t.string :status
      t.jsonb :raw_payload
      t.string :hubspot_deal_id
      t.datetime :last_synced_at

      t.timestamps
    end
  end
end
