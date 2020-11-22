class OrdersController < ApplicationController
  def index
    @orders = Order.where(user_id: current_user.id).order(created_at: :desc)
  end

  def new
    @order = Order.new
    @order.line_items.build
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.save
    @order.update_total_quantity
    # update_total_quantityメソッドは、注文された発注量をitemに反映するメソッドであり、Orderモデルに定義されています。
    redirect_to orders_path
  end

  private

  def order_params
    params.require(:order).permit(line_items_attributes: [:item_id, :quantity])
  end

end
