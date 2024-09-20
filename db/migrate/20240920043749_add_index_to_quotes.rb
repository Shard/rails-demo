class AddIndexToQuotes < ActiveRecord::Migration[7.2]
  def change
    add_index :quotes, :created
  end
end
