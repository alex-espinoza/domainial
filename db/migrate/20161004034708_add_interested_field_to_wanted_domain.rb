class AddInterestedFieldToWantedDomain < ActiveRecord::Migration[5.0]
  def change
    add_column :wanted_domains, :interested?, :integer, null: false, default: 0
  end
end
