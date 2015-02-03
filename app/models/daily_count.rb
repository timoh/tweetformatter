class DailyCount
  include Mongoid::Document

  field :date, type: Date
  field :company_symbol, type: String
  field :count, type: Integer

  validates_uniqueness_of :company_date

  def company_date
    return self.date.to_s + self.company_symbol.to_s
  end
  
end
