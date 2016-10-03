class AddDateTimeFieldsToDropCheck < ActiveRecord::Migration[5.0]
  def change
    add_column :drop_checks, :first_registered_date, :datetime
    add_column :drop_checks, :last_updated_date, :datetime
    add_column :drop_checks, :expiry_date, :datetime
    add_column :drop_checks, :grace_period_ends_date, :datetime
  end
end
