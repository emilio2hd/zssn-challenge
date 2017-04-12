class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :name, limit: 50, null: false
      t.integer :points, null: false
      t.timestamps
    end
  end
end
