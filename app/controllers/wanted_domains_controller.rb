class WantedDomainsController < ApplicationController
  def index
    @wanted_domains = WantedDomain.all
  end
end
