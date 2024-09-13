class CreateQuotes < ActiveRecord::Migration[7.2]
  def change
    create_table :quotes do |t|
      t.decimal :price
      t.datetime :created

      t.timestamps
    end
  end
end
