class Api::WantedDomainsController < ApplicationController
  def create
    @wanted_domain = WantedDomain.new(wanted_domain_params)
    @wanted_domain.name = @wanted_domain.name.strip.downcase
    @wanted_domain.tld = '.io'

    if @wanted_domain.valid? && @wanted_domain.save
      WantedDomainCheckWorker.perform_async(@wanted_domain.id)
      json = {message: "'#{@wanted_domain.name}' has been added as a wanted domain.", word: @wanted_domain.name}
      status = 200
    else
      json = {error: "'#{@wanted_domain.name}' is already being tracked.", word: @wanted_domain.name}
      status = 409
    end

    render json: json,
           status: status
  end

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name)
  end
end
