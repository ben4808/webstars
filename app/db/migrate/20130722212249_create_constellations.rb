class CreateConstellations < ActiveRecord::Migration
  def change
    create_table :constellations do |t|
      t.string :name
      t.string :abbr
    end
  end
end
