class Api::WantedDomainsController < ApplicationController
  def create
    @wanted_domain = WantedDomain.new(wanted_domain_params)
    @wanted_domain.name = @wanted_domain.name.strip.downcase
    @wanted_domain.tld = @wanted_domain.tld.strip.downcase

    if @wanted_domain.valid? && @wanted_domain.save
      WantedDomainCheckEnqueuer.queue(@wanted_domain.tld, @wanted_domain.id)
      json = { message: "'#{@wanted_domain.name_with_tld}' has been added as a wanted domain.",
               word: @wanted_domain.name,
               tld: @wanted_domain.tld
             }
      status = 200
    else
      json = { error: "'#{@wanted_domain.name_with_tld}' is already being tracked.",
               word: @wanted_domain.name,
               tld: @wanted_domain.tld
             }
      status = 409
    end

    render json: json,
           status: status
  end

  def interested
    @wanted_domain = WantedDomain.find(wanted_domain_params[:id])

    if @wanted_domain.interested? == 0
      @wanted_domain.update(interested?: 1)
      json = { message: "'#{@wanted_domain.name_with_tld}' has been marked as interested.",
               interested?: @wanted_domain.interested?,
               interested_text: @wanted_domain.is_interested_button_text
             }
    else
      @wanted_domain.update(interested?: 0)
      json = { message: "'#{@wanted_domain.name_with_tld}' has been unmarked as interested.",
               interested?: @wanted_domain.interested?,
               interested_text: @wanted_domain.is_interested_button_text
             }
    end

    render json: json,
           status: 200
  end

  def check
    @wanted_domain = WantedDomain.find(wanted_domain_params[:id])

    if @wanted_domain.checked? == 1
      @wanted_domain.update(checked?: 2)
      WantedDomainCheckEnqueuer.queue(@wanted_domain.tld, @wanted_domain.id)
      json = { message: "'#{@wanted_domain.name_with_tld}' has been queued to be checked again.",
               checked?: @wanted_domain.checked?,
               checked_text: @wanted_domain.is_being_checked_button_text
             }
    else
      json = { message: "'#{@wanted_domain.name_with_tld}' is already in queue to be checked.",
               checked?: @wanted_domain.checked?,
               checked_text: @wanted_domain.is_being_checked_button_text
             }
    end

    render json: json,
           status: 200
  end

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name, :tld, :id)
  end
end
