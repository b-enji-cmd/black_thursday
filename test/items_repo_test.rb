require 'CSV'
require_relative './test_helper'


class ItemsRepoTest < Minitest::Test

  def setup
    # data = {
    #         :items     => "./dummy_data/dummy_items.csv",
    #         :merchants => "./dummy_data/dummy_merchants.csv"
    #         #Add CSV dummy files
    #         }
    # sales_engine = SalesEngine.new(data)
    @engine = mock
    #
    # @dummy_repo = ItemsRepo.new("./data/items.csv", @engine)

    @dummy_repo = ItemsRepo.new("./dummy_data/dummy_items.csv", @engine)
  end

  def test_it_is
    assert_instance_of ItemsRepo, @dummy_repo
  end

  def test_it_has_attributes
    assert_instance_of Hash , @dummy_repo.collections
  end

  def test_it_can_populate
    assert_instance_of Hash, @dummy_repo.populate_collection
  end

  def test_it_can_gather_all_items
    assert_instance_of Item, @dummy_repo.all[0]
    assert_instance_of Item, @dummy_repo.all[-1]
    assert_equal 5, @dummy_repo.all.length
  end

  def test_it_can_group_by_merchant_id
    assert_equal [1, 2, 3, 4], @dummy_repo.group_by_merchant_id.keys
  end

  def test_it_can_find_by_id
    assert_instance_of Item, @dummy_repo.find_by_id(123)
    assert_nil @dummy_repo.find_by_id("111111")
  end

  def test_it_can_find_by_price
    assert_instance_of Array, @dummy_repo.find_all_by_price(14900)
    price = BigDecimal.new(200 / 100)
    actual = @dummy_repo.find_all_by_price(price)
    assert_instance_of BigDecimal, actual[0].unit_price
    price = BigDecimal.new(46000/100)
    actual = @dummy_repo.find_all_by_price(price)
    assert_instance_of Item, actual[0]
  end


  def test_it_can_find_by_name
    assert_equal 345, @dummy_repo.find_by_name("etsy").id
  end

  def test_it_can_find_by_description
    data_set = @dummy_repo.find_all_with_description("A large Yeti of sorts, casually devours a cow as the others watch numbly.")

    sub_str = ["Size","3m"]
    data_set.each do |item|
      assert_equal true, item.description.include?("size") || item.description.include?("3m")
    end
  end

  def test_it_can_find_by_price_range
    actual = @dummy_repo.find_all_by_price_in_range(100..60000)
    actual_empty = @dummy_repo.find_all_by_price_in_range(1000000..2000000)
    assert_equal 2, actual.count
    assert_equal true, actual.all?{|item| item.class == Item}
    assert_equal 0, actual_empty.count
    assert_equal [], actual_empty
  end

  def test_update
    @dummy_repo.find_by_name("amazon")
    actual = @dummy_repo.find_by_name("amazon")
    assert_equal "amazon", actual.name
    price = BigDecimal.new(4500)
    actual = @dummy_repo.find_all_by_price(price)
    assert_equal "amazon", @dummy_repo.all[2].name
    @dummy_repo.find_all_with_description("sell things")
    assert_equal "we sell things", @dummy_repo.all[2].description

    @dummy_repo.update(567, {id: 567, name: "ebay", description: "we use to sell things", unit_price: BigDecimal.new(6400)})

    actual = @dummy_repo.find_by_name("ebay")
    assert_equal "ebay", actual.name
    price = BigDecimal.new(6400)
    actual = @dummy_repo.find_all_by_price(price)
    assert_equal price, actual[0].unit_price
    assert_equal "ebay", @dummy_repo.all[2].name
    @dummy_repo.find_all_by_price(6400)
    assert_equal 6400, @dummy_repo.all[2].unit_price
  end

  def test_it_can_find_merchant_id
    actual = @dummy_repo.find_all_by_merchant_id(1).flatten
    assert_equal 1,actual[0].merchant_id
    # assert_instance_of Item, actual[1]
  end

  def test_it_can_create_new_item
      data ={
        :id => 910,
        :name => "chipotle",
        :description => "burritos!",
        :unit_price => 49000,
        :merchant_id =>	"5",
        :created_at => "2125-09-22 09:34:06 UTC",
        :updated_at => "2034-09-04 21:35:10 UTC"
      }
      @dummy_repo.create(data)
      assert_instance_of Item, @dummy_repo.all[-1]
      assert_equal true, @dummy_repo.all.last.id == 790
      assert_equal 790, @dummy_repo.all[-1].id
      p @dummy_repo.all[-1].unit_price_to_dollars
    end

  def test_it_can_delete_items
    data ={
      :id => "790",
      :name => "chipotle",
      :description => "burritos!",
      :unit_price => "49000",
      :merchant_id =>	"5",
      :created_at => "2125-09-22 09:34:06 UTC",
      :updated_at => "2034-09-04 21:35:10 UTC"
    }

    @dummy_repo.create(data)
    @dummy_repo.delete(790)

    assert_nil nil, @dummy_repo.find_by_id(790)
  end


end
