class CompetitorDomainsController < ApplicationController
  def index
    @revenue_by_tld = CompetitorDomain.group(:tld).sum(:price).sort_by {|tld, price| price}.reverse
    @last_30_domains_sold = CompetitorDomain.where(active: 0).order(sold_date: :desc).limit(50)
  end
end
