class RemoveNameIndexOnWantedDomains < ActiveRecord::Migration[5.0]
  def change
    remove_index :wanted_domains, :name
  end
end
