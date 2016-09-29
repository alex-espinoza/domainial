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
      WantedDomainCheckWorker.perform_async(domain_id: @wanted_domain.id)
      flash[:success] = "#{@wanted_domain.name_with_tld} added."
      redirect_to root_path
    else
      flash.now[:error] = @wanted_domain.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def check_all
    WantedDomain.queue_all_unchecked

    flash[:notice] = 'All unchecked domains have been requeued.'
    redirect_to root_path
  end

  private

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name)
  end
end
