class CreateHipStars < ActiveRecord::Migration
  def change
    create_table :hip_stars do |t|
      t.integer :hip
      t.integer :hd
      t.belongs_to :constellation
      t.decimal :ra_deg, :precision => 11, :scale => 8
      t.decimal :dec_deg, :precision => 10, :scale => 8
      t.decimal :mag, :precision => 4, :scale => 2
      t.string :bayer
      t.string :flam
      t.string :gould
      t.string :name
      t.boolean :is_common, :default => 0, :null => false
      t.string :var_name
    end
  end
end
