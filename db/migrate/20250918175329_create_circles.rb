class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.references :frame, null: false, foreign_key: true
      t.decimal :x
      t.decimal :y
      t.decimal :diameter

      t.timestamps
    end
  end
end
