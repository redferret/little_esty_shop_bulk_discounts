class Merchants::BulkDiscountsController < ApplicationController
  before_action :set_merchant

  def index
    @upcoming_holidays = NagerAPI::Client.upcoming_holidays
  end
  
  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
  end

  def create
    if @merchant.bulk_discounts.create!(bulk_discount_params)
      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      flash[:alert] = "Couldn't create discount"
      redirect_to edit_merchant_bulk_discount_path(@merchant, @bulk_discount)
    end
  end

  def update
    @bulk_discount = BulkDiscount.find(params[:id])

    if @bulk_discount.update!(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, @bulk_discount)
    else
      flash[:alert] = "Couldn't update discount"
      redirect_to edit_merchant_bulk_discount_path(@merchant, @bulk_discount)
    end
  end

  def destroy
    bulk_discount = BulkDiscount.find(params[:id])
    if bulk_discount.destroy!
      redirect_to merchant_bulk_discount_path(@merchant, @bulk_discount)
    else
      flash[:alert] = "Couldn't delete discount"
      redirect_to edit_merchant_bulk_discount_path(@merchant, @bulk_discount)
    end
  end
  
  private
  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage_discount, :quantity_threshold)
  end

  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
