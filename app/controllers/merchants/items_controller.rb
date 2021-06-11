class Merchants::ItemsController < ApplicationController
  before_action :find_item_and_merchant, only: [:show, :edit, :update]
  before_action :find_merchant, only: [:new, :create, :index]

  def index
    @enabled_items = @merchant.items.where(status: :enabled)
    @disabled_items = @merchant.items.where(status: :disabled)
  end

  def show

  end

  def edit

  end

  def update
    if @item.update(item_params)
      flash.notice = "Succesfully Updated Item Info!"
      redirect_to merchant_item_path(@merchant, @item)
    else
      flash.notice = "All fields must be completed, get your act together."
      redirect_to edit_merchant_item_path(@merchant, @item)
    end
  end

  def new

  end

  def create
    @merchant.items.create!(item_params)
    redirect_to merchant_items_path(@merchant)
  end

  private
  
  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

  def find_item_and_merchant
    @item = Item.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
