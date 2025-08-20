class CartsController < ApplicationController
  # POST /cart
  def create
    cart = create_cart
    add_product_to_cart(cart, params[:product_id], params[:quantity])
    render json: cart_payload(cart), status: :ok
  end

  # GET /cart
  def show
    cart = current_cart
    render json: cart_payload(cart), status: :ok
  end

  # POST /cart/add_item
  def add_item
    cart = current_cart
    if add_product_to_cart(cart, params[:product_id], params[:quantity]).present?
      render json: cart_payload(cart), status: :ok
    else
      return render json: { error: "Produto não encontrado" }, status: :unprocessable_entity
    end
  end

  # DELETE /cart/:product_id
  def remove_item
    cart = current_cart
    product = Product.find_by(id: params[:product_id])

    return render json: { error: "Produto não encontrado" }, status: :not_found unless product

    cart_item = cart.cart_items.find_by(product_id: product.id)
    return render json: { error: "Produto não está no carrinho" }, status: :unprocessable_entity unless cart_item

    cart_item.destroy
    cart.update!(last_interaction_at: Time.current) # atualiza interação do usuário

    if cart.cart_items.empty?
      cart.destroy
      session.delete(:cart_id)
      render json: { message: "Carrinho vazio. Removido" }, status: :ok
    else
      render json: cart_payload(cart), status: :ok
    end
  end

  private

  def current_cart
    if session[:cart_id]
      Cart.find_by(id: session[:cart_id])
    end
  end

  def create_cart
    cart = Cart.create!
    session[:cart_id] = cart.id

    cart
  end

  def add_product_to_cart(cart, product_id, quantity)
    product = Product.find_by(id: product_id)

    return nil unless product

    item = cart.cart_items.find_or_initialize_by(product: product)
    item.quantity ||= 0
    item.quantity += quantity.to_i
    item.unit_price = product.price
    item.save!

    cart.update!(last_interaction_at: Time.current)

    item
  end

  def cart_payload(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.unit_price.to_f,
          total_price: item.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
