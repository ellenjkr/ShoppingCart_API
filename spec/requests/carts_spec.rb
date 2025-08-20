require 'rails_helper'

RSpec.describe "/carts", type: :request do
  # pending "TODO: Escreva os testes de comportamento do controller de carrinho necessários para cobrir a sua implmentação #{__FILE__}"
  let!(:product1) { Product.create!(name: "Produto X", price: 7.0) }
  let!(:product2) { Product.create!(name: "Produto Y", price: 9.90) }

  describe "POST /cart" do
    it "creates a cart and adds a product" do
      post "/cart", params: { product_id: product1.id, quantity: 2 }, headers: { "Host" => "localhost" }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body["products"].size).to eq(1)
      expect(body["products"].first["quantity"]).to eq(2)
      expect(body["total_price"]).to eq(14.0)
    end
  end
  describe "POST /add_item" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session)
        .to receive(:[]).with(:cart_id).and_return(cart.id)
    end

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end
      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "GET /cart" do
    let(:cart) { Cart.create! }
    let!(:cart_item) { CartItem.create!(cart: cart, product: product1, quantity: 3, unit_price: product1.price) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session)
        .to receive(:[]).with(:cart_id).and_return(cart.id)
    end

    it "returns the cart from the session" do
      get "/cart", headers: { "Host" => "localhost" }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["id"]).to eq(cart.id)
      expect(body["products"].size).to eq(1)
      expect(body["products"].first["quantity"]).to eq(3)
      expect(body["products"].first["total_price"]).to eq(21.0)
      expect(body["total_price"]).to eq(21.0)
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:cart) { Cart.create! }
    let!(:cart_item1) { CartItem.create!(cart: cart, product: product1, quantity: 2, unit_price: product1.price) }
    let!(:cart_item2) { CartItem.create!(cart: cart, product: product2, quantity: 1, unit_price: product2.price) }

    before do
      allow_any_instance_of(ActionDispatch::Request::Session)
        .to receive(:[]).with(:cart_id).and_return(cart.id)
    end

    context "when removing an existing item" do
      it "removes the item from the cart" do
        expect {
          delete "/cart/#{product1.id}", as: :json
        }.to change { cart.reload.cart_items.count }.by(-1)

        expect(cart.cart_items.exists?(product_id: product1.id)).to be_falsey
      end
    end

    context "when removing a non-existent product" do



      it "returns 404" do
        delete "/cart/99999", as: :json
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["error"]).to eq("Produto não encontrado")
      end
    end

    context "when removing the last item" do
      it "destroys the cart and clears session" do
        expect {
          delete "/cart/#{product1.id}", as: :json
          delete "/cart/#{product2.id}", as: :json
        }.to change { Cart.count }.by(-1)

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["message"]).to eq("Carrinho vazio. Removido")
      end
    end
  end

end
