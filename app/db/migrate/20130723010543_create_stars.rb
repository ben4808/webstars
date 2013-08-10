class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.integer :hd
      t.integer :tyc1
      t.integer :tyc2
      t.integer :tyc3
      t.decimal :ra_deg, :precision => 11, :scale => 8
      t.decimal :dec_deg, :precision => 10, :scale => 8
      t.decimal :mag, :precision => 4, :scale => 2
    end
  end
end
