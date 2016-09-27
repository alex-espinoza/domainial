class CreateWantedDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :wanted_domains do |t|
      t.string :name, null: false
      t.string :tld, null: false
      t.integer :checked?, null: false
      t.string :status
      t.datetime :first_registered_date
      t.datetime :last_updated_date
      t.datetime :expiry_date
      t.datetime :grace_period_ends_date
      t.string :backorder
      t.string :owner_name
      t.string :organization_name

      t.timestamps
    end
  end
end
