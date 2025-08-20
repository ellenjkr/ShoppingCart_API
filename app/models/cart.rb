class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def total_price
    cart_items.sum(&:total_price)
  end

  def inactive_for_3_hours?
    last_interaction_at.nil? ||  last_interaction_at.present? && last_interaction_at < 1.minutes.ago
  end

  def abandoned_for_7_days?
    abandoned? && last_interaction_at.present? && last_interaction_at < 2.minutes.ago
  end

  def mark_as_abandoned
    update(abandoned: true) if inactive_for_3_hours?
  end

  def remove_if_abandoned
    destroy if abandoned_for_7_days?
  end
end
