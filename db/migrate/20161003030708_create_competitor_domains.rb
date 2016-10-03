class CreateCompetitorDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :competitor_domains do |t|
      t.string :name
      t.string :tld
      t.integer :number_of_bids
      t.integer :price
      t.datetime :auction_end_date
      t.datetime :auction_start_date

      t.timestamps
    end
  end
end
