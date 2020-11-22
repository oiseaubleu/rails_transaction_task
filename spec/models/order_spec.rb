require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "発注機能" do
    let!(:user1){FactoryBot.create(:user)}
    let!(:user2){FactoryBot.create(:second_user)}
    let!(:item){FactoryBot.create(:item)}


    context "2人のユーザから同時更新された場合" do
      before do
        threads = []
        threads << Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            order = Order.create(user_id: user1.id)
            line_item = LineItem.create(order_id: order.id, item_id: item.id, quantity: 5)
            order.update_total_quantity
          end
        end
        threads << Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            order = Order.create(user_id: user2.id)
            line_item = LineItem.create(order_id: order.id, item_id: item.id, quantity: 5)
            order.update_total_quantity
          end
        end
        threads.each(&:join)
      end

      it { expect(item.reload.total_quantity).to eq(5 + 5) }
    end
  end
end
