require 'faker'

def random_date(start_date, end_date)
  Time.at((end_date.to_f - start_date.to_f) * rand + start_date.to_f)
end

admin = User.find_or_create_by!(
  email: "admin@example.com"
) do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
  user.role = :admin
end

# CNPJs para as lojas
cnpj = ["12345678900123", "12345678900122"]

# Produtos para cada loja
orange_curry_products = [
  "Massaman Curry",
  "Risotto with Seafood",
  "Tuna Sashimi",
  "Fish and Chips",
  "Pasta Carbonara"
]

belly_king_products = [
  "Mushroom Risotto",
  "Caesar Salad",
  "Mushroom Risotto",
  "Tuna Sashimi",
  "Chicken Milanese"
]

# Lojas e produtos
[
  { name: "Orange Curry", products: orange_curry_products, cnpj: cnpj[0] },
  { name: "Belly King", products: belly_king_products, cnpj: cnpj[1] }
].each do |store_info|
  store = Store.find_or_create_by!(name: store_info[:name]) do |store|
    user = User.create!(
      email: "#{store_info[:name].split.map { |s| s.downcase }.join(".")}@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
    )
    store.user = user
    store.cnpj = store_info[:cnpj]
    store.phonenumber = "0012345678"
    store.city = "Belo Horizonte"
    store.cep = "12345678"
    store.state = "Minas Gerais"
    store.neighborhood = "Centro"
    store.address = "Rua A"
    store.numberaddress = "10"
    store.establishment = "Restaurante"
  end

  store_info[:products].each do |dish|
    Product.find_or_create_by!(title: dish, store: store) do |product|
      product.price = 10
      product.description = "Deliciosa comida típica"
      product.category = "Petisco"
      product.portion = "2 pessoas"
    end
  end
end

# Compradores (Buyers)
buyers = User.where(role: :buyer)
if buyers.empty?
  5.times do
    User.create!(
      email: Faker::Internet.email,
      password: "123456",
      password_confirmation: "123456",
      role: :buyer
    )
  end
  buyers = User.where(role: :buyer)
end

# Produtos
products = Product.all

# Pedidos (Orders)
30.times do
  store = Store.order("RANDOM()").first
  buyer = buyers.sample
  order = Order.create!(
    buyer: buyer,
    store: store,
    state: 'created',
    created_at: random_date(DateTime.new(2024, 5, 17), DateTime.new(2024, 6, 16))
  )

  store_products = store.products.sample(2)
  store_products.each do |product|
    OrderItem.create!(
      order: order,
      product: product,
      amount: rand(1..5),
      price: product.price
    )
  end
end

puts "Seed finished"



