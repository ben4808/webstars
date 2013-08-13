class CreateUcacStars < ActiveRecord::Migration
  def change
    create_table :ucac_stars do |t|
      t.decimal :ra_deg, :precision => 11, :scale => 8
      t.decimal :dec_deg, :precision => 10, :scale => 8
      t.decimal :mag, :precision => 4, :scale => 2
    end
  end
end
