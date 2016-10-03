class AddSoldDateToCompetitorDomain < ActiveRecord::Migration[5.0]
  def change
    add_column :competitor_domains, :sold_date, :datetime
  end
end
