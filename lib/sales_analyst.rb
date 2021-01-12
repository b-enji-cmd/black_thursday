require 'CSV'
require_relative './sales_engine'
require_relative './mathable'

class SalesAnalyst
  include Mathable

  attr_reader :engine

  def initialize(engine)
    @engine = engine
  end

 def count_of_total_items_across_all_merchants
   @engine.items_per_merchant.values.flatten.count.to_f
 end

 def count_of_total_merchants
   @engine.items_per_merchant.keys.count
 end

 def average_items_per_merchant
   average(count_of_total_items_across_all_merchants, @engine.total_merchants)
 end

 def count_of_all_items_by_merchant
   items_per = @engine.items_per_merchant
   items_per.map do |merchant, items|
     items.count
   end
 end

 def average_items_per_merchant_standard_deviation
  l_value = count_of_all_items_by_merchant
  r_value = average_items_per_merchant
   final_std_dev(l_value, r_value)
 end

 def one_std_dev_above_avg_std_dev_items_per_merchant
  l_value = average_items_per_merchant_standard_deviation
  r_value = average_items_per_merchant
   sum_of(l_value, r_value)
 end

 def merchants_with_high_item_count
   all_merchants = @engine.merchants.all
   all_merchants.find_all do |merchant|
     items = @engine.find_all_items_by_merchant_id(merchant.id)
     items.count > one_std_dev_above_avg_std_dev_items_per_merchant
   end
 end

 def items_to_be_averaged(merchant_number)
   collector = []
   items_per_merchant = @engine.items_per_merchant
   items_per_merchant.each do |merchant_id, items|
     if merchant_id == merchant_number
       collector << items
     end
   end
   collector.flatten
 end #array of all the items for specific merchant

 def sum_item_price_for_merchant(merchant_number)
   indexed_items = items_to_be_averaged(merchant_number)
   indexed_items.sum {|item| item.unit_price_to_dollars}
 end #returns float of PRICE OF ALL OF THE ITEMS for specific merchant

 def average_item_price_for_merchant(merchant_id)
  r_value = items_to_be_averaged(merchant_id).count
   average(sum_item_price_for_merchant(merchant_id),r_value).to_d
 end # BIGDECIMAL of the average item price for specific merchant

 def merchant_id_collection
   @engine.items_per_merchant.keys
 end

 def average_item_prices_collection
   merchant_id_collection.map do |merchant_id|
     average_item_price_for_merchant(merchant_id)
   end
 end#ALL OF THE AVERAGE ITEM PRICES FOR EACH MERCHANT

 def list_items_price
   @engine.all_items_by_unit_price
 end

 def sum_average_prices_collections
   average_item_prices_collection.sum
 end #TOTAL AVERAGE ITEM PRICE ACROSS ALL MERCHANTS

 def average_average_price_per_merchant
   average(sum_average_prices_collections,merchant_id_collection.count).to_d
 end

 def item_price_std_dev
  arg_1 = average_item_prices_collection
  arg_2 = average_average_price_per_merchant

  final_std_dev(arg_1, arg_2)
 end

 def double_item_price_standard_deviation
   item_price_std_dev * 2
 end

 def golden_items_critera
   l_value = double_item_price_standard_deviation
   r_value = average_average_price_per_merchant
   l_value + r_value
 end

 def item_collection
   @engine.items_per_merchant.values.flatten
 end

 def golden_items
   items =item_collection
   items.find_all do |item|
     item.unit_price > golden_items_critera
   end
 end
end
