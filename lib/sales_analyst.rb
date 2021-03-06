require 'CSV'
require_relative './sales_engine'
require_relative './mathable'

class SalesAnalyst
  include Mathable

  attr_reader :engine

  def initialize(engine)
    @engine = engine
    @golden_items_critera ||= golden_items_critera
  end

 def count_of_total_items_across_all_merchants
   @engine.items_per_merchant.values.flatten.count.to_f
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
 end

 def sum_item_price_for_merchant(merchant_number)
   indexed_items = items_to_be_averaged(merchant_number)
   indexed_items.sum {|item| item.unit_price_to_dollars}
 end

 def average_item_price_for_merchant(merchant_id)
  r_value = items_to_be_averaged(merchant_id).count
   average(sum_item_price_for_merchant(merchant_id),r_value).to_d
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
   @engine.all_items_by_unit_price
 end

 def sum_average_prices_collections
   average_item_prices_collection.sum
 end

 def average_average_price_per_merchant
   average(sum_average_prices_collections, merchant_id_collection.count).to_d
 end

 def item_price_std_dev
  arg_1 = @engine.items.all.map {|item| item.unit_price}
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

 def golden_items
   @engine.items.collections.reduce([]) do |items, item|
     if item[1].unit_price > @golden_items_critera
       items << item[1]
     end
     items
   end
 end

 def group_invoices_by_merchant_id_values
   @engine.group_invoices_by_merchant_id.map do |key, value|
    value.count
  end
 end

 def group_invoices_sum
   group_invoices_by_merchant_id_values.sum.to_f
 end

 def group_total_invoice_merchant_sum
   group_invoices_by_merchant_id_values.count.to_f
 end

 def average_invoices_per_merchant
   (group_invoices_sum/group_total_invoice_merchant_sum).round(2)
 end

 def average_invoices_per_merchant_standard_deviation
   final_std_dev(group_invoices_by_merchant_id_values, average_invoices_per_merchant)
 end

 def top_merchants_by_invoice_count
   collector = []
   @engine.group_invoices_by_merchant_id.each do |key, value|
     if value.count > (average_invoices_per_merchant + (average_invoices_per_merchant_standard_deviation * 2))
       collector << @engine.merchants.find_by_id(key)
     end
   end
   collector
 end

 def bottom_merchants_by_invoice_count
   collector = []
   @engine.group_invoices_by_merchant_id.each do |key, value|
     if value.count < (average_invoices_per_merchant - (average_invoices_per_merchant_standard_deviation * 2))
       collector << @engine.merchants.find_by_id(key)
     end
   end
   collector
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
   a = []
   @engine.invoices.all_invoices_by_day.find_all do |key, value|
     if value.count > invoice_one_std_dev_above
       return a.push(key)
       end
     end
 end

 def invoice_status(status)
   percentage(@engine.invoices.find_all_by_status(status).length,
   @engine.invoices.all.length)
 end

 def get_merchants_with_only_one_item
   items_per = @engine.items_per_merchant
   items_per.find_all do |id,items|
     items.length == 1
   end
 end

 def merchants_with_only_one_item
   merchant_list = get_merchants_with_only_one_item

   merchant_list.flat_map do |pair|
     @engine.find_merchant(pair[0]).values
   end
   #only_merchants.flatten
 end

 def invoice_paid_in_full?(invoice_id)
   transactions = @engine.transactions_by_result(:success)
   transactions.any? do |transaction|
     invoice_id == transaction.invoice_id
   end
 end

 def invoice_total(invoice_id)
    if invoice_paid_in_full?(invoice_id) == true
      @engine.invoice_by_invoice_id(invoice_id).sum do |invoice|
        invoice.unit_price * invoice.quantity
      end
    end
  end

 def invoices_group_by_status
   @engine.invoices.collections.group_by do |key, value|
     value.status
   end
 end

 def invoices_with_pending_status
   invoices_group_by_status[:pending]
 end

 def extract_merchant_ids
   invoices_with_pending_status.map do |invoice|
     invoice[1].merchant_id
   end.uniq
 end

 def merchants_with_pending_invoices
  extract_merchant_ids.map do |id|
    @engine.merchants.find_by_id(id)
   end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_with_only_one_item.find_all do |merchant|
      merchant.created_at.strftime("%B") == month
    end
  end

  def successful_transactions
    @engine.transactions_by_result(:success)
  end

  def successful_transaction_invoice_ids
    successful_transactions.map do |transaction|
      transaction.invoice_id
    end
  end

  def successful_transactions_invoice_item_items
    @engine.invoice_items.collections.find_all do |key, invoice_item|
      successful_transaction_invoice_ids.include?(key.to_i)
    end
  end

  def retrieve_merchant_instance(merchant_id)
    @engine.merchants.find_by_id(merchant_id)
  end

  def retrieve_merchants_items(merchant_id)
    @engine.items.find_all_by_merchant_id(merchant_id)
  end

  def merchants_item_ids(merchant_id)
    retrieve_merchants_items(merchant_id).map do |item|
      item.id
    end
  end

  def merchants_invoice_items(merchant_id)
    collector = []
    successful_transactions_invoice_item_items.each do |id, invoice_item|
      if merchants_item_ids(merchant_id).include?(invoice_item.item_id)
        collector << invoice_item
      end
    end
    collector
  end

  def revenue_by_merchant(merchant_id)
    total_revenue = 0
    merchants_invoice_items(merchant_id).each do |invoice_item|
      total_revenue += (invoice_item.quantity * invoice_item.unit_price)
    end
    total_revenue
  end

  def merchant_id_collections
    merchant_revenues = {}
    @engine.merchants.collections.each do |key, values|
      merchant_revenues[key.to_i] = revenue_by_merchant(key.to_i)
    end
    merchant_revenues
  end

  def merchant_revenue_collections_sorted
    merchant_id_collections.values.sort.reverse
  end

  def top_revenue_earners_merchant_ids
    top_revenue_earners_ids = []
    merchant_revenue_collections_sorted.each do |revenue|
      merchant_id_collections.each do |merchant_id, merchant_revenue|
        if merchant_revenue == revenue
          top_revenue_earners_ids << merchant_id
        end
      end
    end
    top_revenue_earners_ids
  end

  def top_revenue_earners_merchant_instances
    top_revenue_earners_merchant_ids.map do |id|
      @engine.merchants.find_by_id(id)
    end
  end

  def top_revenue_earners(x = 20)
    top_revenue_earners_merchant_instances[0..(x-1)]
  end

  def revenue_from_invoice_id(invoice_id)
    @engine.invoice_items_by_id(invoice_id).sum do |key,value|
      value.unit_price * value.quantity
    end
  end

  def valid_invoices(date)
    @engine.invoices_by_date(date).select do |id, invoice_item|
      invoice_paid_in_full?(id.to_i)
    end
  end

  def total_revenue_by_date(date)
    invoices = valid_invoices(date)
    addition = 0
    invoices.each do |id,invoice_item|

      addition = revenue_from_invoice_id(id.to_i)
    end
    addition
  end
end
