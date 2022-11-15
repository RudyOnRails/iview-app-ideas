# frozen_string_literal: true

class ApiController < ApplicationController
  def stock_and_pricing
    byebug
    # In the real world this call takes a second or two.
    sleep 1

    @stock_output = output[:stock].deep_symbolize_keys

    @stock_total = @stock_output[:current][:total]
    @stock_unit = @stock_output[:unit][:long][@stock_total == 1 ? :singular : :plural]

    @stock_total_reserved = @stock_output[:total_reserved]
    @stock_total_reserved_unit = @stock_output[:unit][:long][@stock_total_reserved == 1 ? :singular : :plural]

    @has_stock = @stock_total.present? && @stock_total.to_f.positive?
    @has_availability = @stock_output[:availability].present?
    @incoming_stock = @stock_output[:expected]

    # Get all bolts and separate them into "regular bolts" and "small cuts"
    @bolts = @stock_output[:current][:bolts]

    # Small cuts applies to fabric sold by the yard, excluding Clarencehouse
    if !clarencehouse? && @product.fabric? && @product.measured_unit["long"]["singular"] == "Yard"
      @regular_bolts, @small_cuts = @bolts.partition { |_bolt, lot| lot[:quantity].to_f >= 5 } if @bolts.present?
    else
      @regular_bolts = @bolts
      @small_cuts = nil
    end

    # Group and sort by dye lot number
    @regular_bolts_dye_lots = @regular_bolts.group_by { |_bolt, lot| lot[:dye_lot] } if @regular_bolts.present?
    @small_cuts_dye_lots = @small_cuts.group_by { |_bolt, lot| lot[:dye_lot] } if @small_cuts.present?
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def set_product
    @product = Product.find(params[:sku])
  end
end
