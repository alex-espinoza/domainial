class AddStatusCodeToWantedDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :wanted_domains, :status_code, :integer
  end
end
