class Merchants::DashboardController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @invoices_ready_to_ship = Invoice.invoices_ready_to_ship(@merchant.id)
  end
end
