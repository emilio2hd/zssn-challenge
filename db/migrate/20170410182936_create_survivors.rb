class CreateSurvivors < ActiveRecord::Migration[5.0]
  def change
    create_table :survivors do |t|
      t.string :name, limit: 255, null: false
      t.integer :age, null: false
      t.integer :gender, null: false
      t.decimal :last_location_lati, null: false, precision: 10, scale: 6 # 11.1 cm distance
      t.decimal :last_location_long, null: false, precision: 10, scale: 6
      t.integer :status, default: 0
      t.integer :flag_counter, default: 0

      t.timestamps
    end

    create_table :survivor_items do |t|
      t.references :survivor, foreign_key: true
      t.references :resource, foreign_key: true
      t.integer :quantity, null: false, default: 0
    end

    add_index :survivor_items, [:survivor_id, :resource_id], unique: true
  end
end
