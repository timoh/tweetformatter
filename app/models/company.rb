class Company
  include Mongoid::Document
  include Mongoid::Timestamps

  field :stock_symbol, type: String
  field :company_name, type: String

  has_many :quotes

  validates_uniqueness_of :stock_symbol
  validates_presence_of :stock_symbol
end
