class AddBackorderStatusToWantedDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :wanted_domains, :backorder_status, :integer
  end
end
