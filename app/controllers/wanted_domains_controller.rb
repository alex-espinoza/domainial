class WantedDomainsController < ApplicationController
  def index
    @wanted_domains = WantedDomain.all
  end

  def new
    @wanted_domain = WantedDomain.new
  end

  def create
    @wanted_domain = WantedDomain.new(wanted_domain_params)
    @wanted_domain.tld = '.io'

    if @wanted_domain.valid? && @wanted_domain.save
      redirect_to root_path
    else
      render 'create.html'
    end
  end

  private

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name)
  end
end
