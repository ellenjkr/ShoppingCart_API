class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    # Melhor desempenho
    # Cart.where(abandoned: false).where("updated_at < ?", 3.hours.ago)
        # .update_all(abandoned: true, updated_at: Time.current)
      # Cart.where(abandoned: true).where("updated_at < ?", 7.days.ago).destroy_all

    # De acordo com métodos definidos para a solução
    Cart.find_each do |cart|
      cart.mark_as_abandoned
      cart.remove_if_abandoned
    end
  end
end
