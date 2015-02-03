class HomeController < ApplicationController
  def index
    @counts = DailyCount.all
    render json: @counts, :only => ["date", "company_symbol", "count"]
  end
end
