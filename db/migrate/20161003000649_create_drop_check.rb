class CreateDropCheck < ActiveRecord::Migration[5.0]
  def change
    create_table :drop_checks do |t|
      t.integer :status_code
      t.references :wanted_domain

      t.timestamps
    end
  end
end
