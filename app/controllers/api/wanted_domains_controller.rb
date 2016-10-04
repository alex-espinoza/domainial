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

  def interested
    @wanted_domain = WantedDomain.find(wanted_domain_params[:id])


    if @wanted_domain.interested? == 0
      @wanted_domain.update(interested?: 1)
      json = {message: "'#{@wanted_domain.name}' has been marked as interested.", interested?: @wanted_domain.interested?, interested_text: @wanted_domain.is_interested_button_text}
    else
      @wanted_domain.update(interested?: 0)
      json = {message: "'#{@wanted_domain.name}' has been unmarked as interested.", interested?: @wanted_domain.interested?, interested_text: @wanted_domain.is_interested_button_text}
    end

    render json: json,
           status: 200
  end

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name, :id)
  end
end
