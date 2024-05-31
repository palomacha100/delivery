class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    if User.column_names.include?('role') && User.where(role: User.roles[:buyer]).exists?
    add_column :users, :name, :string
    add_column :users, :cpf, :string
    add_column :users, :phonenumber, :string
    add_column :users, :cep, :string
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :neighborhood, :string
    add_column :users, :address, :string
    add_column :users, :numberaddress, :string
    add_column :users, :complementaddress, :string
    end
  end
end
