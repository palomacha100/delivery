class Store < ApplicationRecord
  validates :name, presence: true, length: {minimun: 3}
end
