require 'time'
require 'bigdecimal/util'
class Invoice

  attr_reader :id,
              :customer_id,
              :merchant_id,
              :status,
              :created_at,
              :updated_at

  def initialize (data, repository)
    @id          = data[:id].to_i
    @customer_id = data[:customer_id].to_i
    @merchant_id = data[:merchant_id].to_i
    @status      = data[:status].intern
    @created_at  = Time.parse(data[:created_at].to_s)
    @updated_at  = Time.parse(data[:updated_at].to_s)
    #@repository  = repository
  end

  def update_attributes (new_attributes)
    @status     = new_attributes[:status] unless new_attributes[:status] == nil
    @updated_at = new_attributes[:updated_at] = Time.now
  end

end
