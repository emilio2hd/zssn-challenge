class CreateInfectedFlags < ActiveRecord::Migration[5.0]
  def change
    create_table :infected_flags do |t|
      t.integer :infected_id, references: :survivors, foreign_key: true
      t.integer :reporter_id, references: :survivors, foreign_key: true
    end

    add_index :infected_flags, [:infected_id, :reporter_id], unique: true
  end

  add_column :survivors, :flags_count, :integer, null: false, default: 0
end
