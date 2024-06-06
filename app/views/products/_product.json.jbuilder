json.extract! product, :id, :title, :created_at, :updated_at, :price, :description, :category, :store_id

if product.image.attached?
  json.image_url rails_blob_url(product.image, only_path: true)
  json.thumbnail_url rails_representation_url(product.image.variant(resize_to_limit: [100, 100], 
  monochrome: true), only_path: true)
end

json.url store_products_url(product.store, format: :json)
