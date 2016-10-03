class AddActiveAndSourceColumnToCompetitorDomain < ActiveRecord::Migration[5.0]
  def change
    add_column :competitor_domains, :active, :integer
    add_column :competitor_domains, :source, :string
  end
end
