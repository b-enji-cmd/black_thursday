require 'CSV'
require_relative './sales_engine'
require_relative './mathable'

class SalesAnalyst
  include Mathable

  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end

 def total_items_across_all_merchants
   @engine.items_per_merchant.values.flatten.count.to_f
 end

 def total_merchants
   @engine.items_per_merchant.keys.count
 end

 def average_items_per_merchant
   average(total_items_across_all_merchants, @engine.total_merchants)
 end



 def all_items_by_merchant
   @engine.items_per_merchant.map do |merchant, items|
     items.count
   end
 end

 def average_items_per_merchant_standard_deviation
   final_std_dev(all_items_by_merchant, average_items_per_merchant)
 end

 def one_std_dev_above
   sum_of(average_items_per_merchant_standard_deviation, average_items_per_merchant)
 end

 def merchants_with_high_item_count
   @engine.merchants.all.find_all do |merchant|
     @engine.find_all_items_by_merchant_id(merchant.id).count > one_std_dev_above
   end
 end

 def items_to_be_averaged(merchant_number)
   collector = []
   @engine.items_per_merchant.each do |merchant_id, items|
     if merchant_id == merchant_number
       collector << items
     end
   end
   collector.flatten
 end

 def sum_item_price_for_merchant(merchant_number)
   total_price = 0
   items_to_be_averaged(merchant_number).each do |item|
     total_price += item.unit_price
   end
   total_price
 end

 def average_item_price_for_merchant(merchant_id)
   average = sum_item_price_for_merchant(merchant_id) / items_to_be_averaged(merchant_id).count
   average.round(2)
 end

 def merchant_id_collection
   @engine.items_per_merchant.keys
 end

 def average_item_prices_collection
   merchant_id_collection.map do |merchant_id|
     average_item_price_for_merchant(merchant_id)
   end
 end

 def list_items_price
   @engine.items.all.group_by{|item|item.unit_price}
 end

 def sum_average_prices_collections
   average_item_prices_collection.sum
 end

 def average_average_price_per_merchant
   average = (sum_average_prices_collections / merchant_id_collection.count)
   average.round(2)
 end

 def difference_of_item_prices_and_total_average_item_prices
   average_item_prices_collection.map do |average|
     average - average_average_price_per_merchant
   end
 end

 def squares_of_average_prices_differences
   difference_of_item_prices_and_total_average_item_prices.map do |number|
     number ** 2
   end
 end

 def sum_of_square_item_price_differences
   squares_of_average_prices_differences.sum
 end

 def std_dev_item_price_variance
   merchant_id_collection.count - 1
 end

 def item_price_sum_and_variance_quotient
   sum_of_square_item_price_differences / std_dev_item_price_variance
 end

 def item_price_standard_deviation
   (item_price_sum_and_variance_quotient ** 0.5).round(2)
 end

 def double_item_price_standard_deviation
   item_price_standard_deviation * 2
 end

 def golden_items_critera
   double_item_price_standard_deviation + average_average_price_per_merchant
 end

 def item_collection
   @engine.items_per_merchant.values.flatten
 end

 def golden_items
   item_collection.find_all do |item|
     item.unit_price > golden_items_critera
   end
 end

 def average_invoices_by_day
   average(@engine.total_of_all_invoices.flatten.count.to_f, @engine.invoices.all_invoices_by_day.keys.length)
 end

 def all_invoices_by_day_length_array
   @engine.total_of_all_invoices.map{|day|day.length}
 end


 def average_invoices_by_day_std_dev
   final_std_dev(all_invoices_by_day_length_array, average_invoices_by_day)
 end

 def invoice_one_std_dev_above
   sum_of(average_invoices_by_day_std_dev, average_invoices_by_day)
 end

 def top_days_by_invoice_count
   a = @engine.invoices.all_invoices_by_day.values.flatten
     a.map do |a|
     @engine.finding_invoices_by_day(a.created_at.strftime("%A")).count > invoice_one_std_dev_above
   end
 end

 def invoice_status(status)
   percentage(@engine.invoices.find_all_by_status(status).length,
   @engine.invoices.all.length)
 end

end
