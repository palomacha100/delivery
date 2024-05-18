class AddFieldsToStore < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :cnpj, :string
    add_column :stores, :phonenumber, :string
    add_column :stores, :city, :string
    add_column :stores, :cep, :string
    add_column :stores, :state, :string
    add_column :stores, :neighborhood, :string
    add_column :stores, :address, :text
    add_column :stores, :numberadress, :string
    add_column :stores, :complementadress, :string
    add_column :stores, :establishment, :string
  end
end
