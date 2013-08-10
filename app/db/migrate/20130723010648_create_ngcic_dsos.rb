class CreateNgcicDsos < ActiveRecord::Migration
  def change
    create_table :ngcic_dsos do |t|
      t.string :ngc
      t.string :ic
      t.belongs_to :obj_type
      t.belongs_to :constellation
      t.decimal :ra_deg, :precision => 11, :scale => 8
      t.decimal :dec_deg, :precision => 10, :scale => 8
      t.decimal :mag, :precision => 4, :scale => 2
      t.decimal :size_maj, :precision => 6, :scale => 2
      t.decimal :size_min, :precision => 6, :scale => 2
      t.integer :pa
      t.string :name
      t.string :description
      t.string :other_ngc
      t.string :mess
      t.string :cald
      t.string :ugc
      t.string :mcg
      t.string :cgcg
      t.string :pgc
      t.string :arp
      t.string :eso
      t.string :pk
      t.string :ocl
      t.string :gcl
    end
  end
end
