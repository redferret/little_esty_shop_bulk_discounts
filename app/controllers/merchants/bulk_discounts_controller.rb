class Merchants::BulkDiscountsController < ApplicationController
  before_action :set_merchant

  def index
    @upcoming_holidays = NagerAPI::Client.upcoming_holidays
  end
  
  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end
  
  private
  def set_merchant_discount_models
    @merchant = Merchant.find(params[:merchant_id])
  end
end
