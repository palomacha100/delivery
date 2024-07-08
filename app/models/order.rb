class Order < ApplicationRecord
    belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
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
      
      event :accept do
        transition payment_confirmed: :accepted
      end
  
      event :ready do
        transition accepted: :ready_to_dispatch
      end
  
      event :dispatch do
        transition ready_to_dispatch: :dispatched
      end
  
      event :deliver do
        transition dispatched: :delivered
      end
  
      event :cancel do
        transition [:created, :payment_pending, :payment_failed, :payment_confirmed,
                    :sent_to_seller, :accepted, :preparing, :dispatched] => :canceled
      end
    end
  
    private
  
    def buyer_role
      if buyer.nil? || !buyer.buyer?
        errors.add(:buyer, "should be a `user.buyer`")
      end
    end
  end
  
