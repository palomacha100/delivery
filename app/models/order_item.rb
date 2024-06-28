class OrderItem < ApplicationRecord
    belongs_to :order 
    belongs_to :product


    validate :store_product

    def store_product
        if product.store != order.store
            errors.add(
                :product,
                "product should belong to `Store`: #{order.store.name}"
            )
        end
    end
end
