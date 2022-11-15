if current_user.has_role?(:view_net_pricing_usd) || current_user.has_role?(:view_net_pricing_cad)
  json.pricing do
    json.retail do
      json.base do
        json.usd product.base_price__retail(:usd, :unit, :single)
        json.cad product.base_price__retail(:cad, :unit, :single)
      end

      json.markup do
        json.usd product.retail_price(account: @account, currency: :usd, unit: :unit, type: :single)
        json.cad product.retail_price(account: @account, currency: :cad, unit: :unit, type: :single)
      end

      json.customer do
        json.usd product.your_price_retail(@account, :usd, :unit)
        json.cad product.your_price_retail(@account, :cad, :unit)
      end
    end

    json.net do
      json.base do
        json.usd product.base_price__net(:usd, :unit, :single)
        json.cad product.base_price__net(:cad, :unit, :single)
      end

      json.account_cost do
        json.usd product.your_price_net(@account, :usd, :unit)
        json.cad product.your_price_net(@account, :cad, :unit)
      end

      json.piece do
        json.usd product.your_price_net(@account, :usd, :piece)
        json.cad product.your_price_net(@account, :cad, :piece)
      end

      json.halfpiece do
        json.usd product.your_price_net(@account, :usd, :halfpiece)
        json.cad product.your_price_net(@account, :cad, :halfpiece)
      end

      json.customer do
        json.unit product.order_price__net(current_user, :unit)
        json.piece product.order_price__net(current_user, :piece)
        json.halfpiece product.order_price__net(current_user, :halfpiece)
      end
    end
  end
end

if current_user.has_role?(:view_stock)
  json.stock product.stock(current_user)&.merge(unit: product.measured_unit)
end

if product.measured_unit["uom_display_text"].present?
  json.uom_display_text product.measured_unit["uom_display_text"]
end

if product.wallcovering?
  json.measured_unit product.measured_unit["long"]["singular"].downcase
  json.order_increment product.wallcovering_data.average_bolt.to_f
end
