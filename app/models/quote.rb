class Quote
  include Mongoid::Document
  include Mongoid::Timestamps

  field :stock_symbol, type: String
  field :bid_price, type: Float
  field :timestamp, type: DateTime
  field :quote_payload, type: Hash

  belongs_to :company

  validates_presence_of :stock_symbol, :bid_price, :timestamp, :quote_payload
end
