require 'simplecov'
SimpleCov.start
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'
require 'Minitest/autorun'
require 'Minitest/pride'
require 'pry'
require 'mocha/minitest'
require './lib/items'
require './lib/items_repo'
require './lib/merchant'
require './lib/merchant_repository'
require './lib/sales_engine'
require './lib/invoice'
require './lib/invoice_repo'
require './lib/transaction'
require './lib/transaction_repo'
require './lib/invoice_item_repo'
require './lib/invoice_item'