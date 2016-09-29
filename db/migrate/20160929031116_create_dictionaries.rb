class CreateDictionaries < ActiveRecord::Migration[5.0]
  def change
    create_table :dictionaries do |t|
      t.string :word, null: false
      t.string :first_character, null: false
      t.string :definition_url
      t.integer :interested?, null: false, default: 0

      t.timestamps
    end
  end
end
