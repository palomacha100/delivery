class Order < ApplicationRecord
    belongs_to :buyer, class_name: "User"
    belongs_to :store
    has_many :order_items
    has_many :products, through: :order_items
    accepts_nested_attributes_for :order_items, allow_destroy: true

    validate :buyer_role

    state_machine initial: :created do
        event :pay do
            transition created: :payment_pending
        end
    
        event :confirm_payment do
            transition payment_pending: :payment_confirmed
        end
    
        event :payment_failed do
            transition payment_pending: :payment_failed
        end
    
        event :send_to_seller do
            transition payment_confirmed: :sent_to_seller
        end
    
        event :accept do
            transition sent_to_seller: :accepted
        end
    
        event :prepare do
            transition accepted: :preparing
        end
    
        event :dispatch do
            transition preparing: :dispatched
        end
    
        event :deliver do
            transition dispatched: :delivered
        end
    
        event :complete do
            transition delivered: :completed
        end
    
        event :cancel do
            transition [:created, :payment_pending, :payment_failed, :payment_confirmed, :sent_to_seller, :accepted, :preparing, :dispatched] => :canceled
        end
    end
    


    private

     def buyer_role
        if !buyer.buyer?
            errors.add(:buyer, "should be a `user.buyer`")
        end
    end
end
