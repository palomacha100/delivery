class AddFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :description, :text
    add_column :products, :category, :string
    add_column :products, :portion, :string
  end
end
