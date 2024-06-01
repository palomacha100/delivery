class AddActiveToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :active, :boolean
  end
end
