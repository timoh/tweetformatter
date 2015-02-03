class DailyCount
  include Mongoid::Document

  field :date, type: Date
  field :company_symbol, type: String
  field :count, type: Integer

  validates_uniqueness_of :company_date

  def company_date
    return self.date.to_s + self.company_symbol.to_s
  end

  def self.all_counts_as_csv
    require 'csv'
    daily_counts = DailyCount.all

    all_companies = Set.new
    all_companies << daily_counts.distinct(:company_symbol)
    all_companies = all_companies.to_a.sort

    header_row = Array.new
    header_row.push "Date"
    header_row = header_row.concat(all_companies[0])
    # all_companies.each do |cmp|
    #   puts cmp
    #   header_row << cmp
    # end

    all_dates = Set.new
    all_dates << daily_counts.distinct(:date)
    dates_sorted = all_dates.to_a[0].sort

    file_path = Dir.pwd + '/public/output.csv'
    CSV.open(file_path, "wb") do |csv|

      csv << header_row

      dates_sorted.each do |this_date|
        final_array = Array.new
        final_array << this_date.strftime("%Y-%m-%d").to_s # as the first column, push the date

        all_companies[0].each do |company| # as the following columns, push the ordered per-company counts
          per_company_count = 0

          dlcnt = DailyCount.where(:date => this_date.to_s).where(:company_symbol => company.to_s)

          dlcnt.each do |dc_obj|
            per_company_count = per_company_count.to_i+dc_obj.count.to_i
          end

          final_array << per_company_count.to_i
        end

        csv << final_array
      end
    end

    return true

  end
  
end
