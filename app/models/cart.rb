class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    cart_items.sum(&:total_price)
  end

  def inactive_for_3_hours?
    updated_at < 3.hours.ago
  end

  def abandoned_for_7_days?
    abandoned? && updated_at < 7.days.ago
  end
end
