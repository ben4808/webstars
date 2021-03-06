class CreateOtherDsos < ActiveRecord::Migration
  def change
    create_table :other_dsos do |t|
      t.string :name
      t.belongs_to :obj_type
      t.decimal :ra_deg, :precision => 11, :scale => 8
      t.decimal :dec_deg, :precision => 10, :scale => 8
      t.decimal :size_maj, :precision => 6, :scale => 2
      t.decimal :size_min, :precision => 6, :scale => 2
      t.integer :pa
      t.decimal :mag, :precision => 4, :scale => 2
    end
  end
end
