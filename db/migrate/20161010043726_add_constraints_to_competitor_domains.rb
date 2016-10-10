class AddConstraintsToCompetitorDomains < ActiveRecord::Migration[5.0]
  def change
    change_column_null :competitor_domains, :name, false
    change_column_null :competitor_domains, :tld, false
    change_column_null :competitor_domains, :price, false
    change_column_null :competitor_domains, :source, false
    change_column_null :competitor_domains, :active, false
  end
end
