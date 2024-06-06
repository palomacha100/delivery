class AddThemeToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :theme, :string
  end
end
