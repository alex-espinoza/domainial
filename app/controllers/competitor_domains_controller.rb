class CompetitorDomainsController < ApplicationController
  def index
    @revenue_by_tld = CompetitorDomain.group(:tld).sum(:price).sort_by {|tld, price| price}.reverse
  end
end
