admin = User.find_by(
    email: "admin@example.com"
)
if !admin
    admin = User.new(
        email: "admin@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :admin
    )
    admin.save!
end

cnpj = ["12345678900123", "12345678900122"]

[
    "Orange Curry",
    "Belly King"
].each_with_index do |store, index|
    user = User.new(
        email: "#{store.split.map { |s| s.downcase }.join(".")}@example.com",
        password: "123456",
        password_confirmation: "123456",
        role: :seller
    )
    user.save!
 Store.find_or_create_by!(
 name: store, user: user, cnpj: cnpj[index], phonenumber: "0012345678", 
 city: "Belo Horizonte", cep: "12345678", state: "Minas Gerais", neighborhood: "Centro", 
 address: "Rua A", numberadress: "10", establisment: "Comida chinesa", 
 image: "https://cdn.pixabay.com/photo/2024/04/01/05/18/green-8667981_1280.jpg",
 )
end

[
 "Massaman Curry",
 "Risotto with Seafood",
 "Tuna Sashimi",
 "Fish and Chips",
 "Pasta Carbonara"
].each do |dish|
 store = Store.find_by(name: "Orange Curry")
 Product.find_or_create_by!(
 title: dish, store: store, price: 10
 )
end
[
 "Mushroom Risotto",
 "Caesar Salad",
 "Mushroom Risotto",
 "Tuna Sashimi",
 "Chicken Milanese"
].each do |dish|
 store = Store.find_by(name: "Belly King")
 Product.find_or_create_by!(
 title: dish, store: store, price: 10, description: "Deliciosa comida típica", 
 image: "https://cdn.pixabay.com/photo/2024/04/01/05/18/green-8667981_1280.jpg", 
 category: "Petisco", 
 portion: "2 pessoas"
 )
end
