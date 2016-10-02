class WantedDomainsController < ApplicationController
  def index
    @wanted_domains_being_released = WantedDomain.where(grace_period_ends_date: Time.now..1.month.from_now, status_code: 0).order(:grace_period_ends_date)
  end

  def new
    @wanted_domain = WantedDomain.new
  end

  def create
    @wanted_domain = WantedDomain.new(wanted_domain_params)
    @wanted_domain.name = @wanted_domain.name.strip.downcase
    @wanted_domain.tld = '.io'

    if @wanted_domain.valid? && @wanted_domain.save
      WantedDomainCheckWorker.perform_async(@wanted_domain.id)
      flash[:success] = "#{@wanted_domain.name_with_tld} added."
      redirect_to wanted_domains_all_path
    else
      flash.now[:error] = @wanted_domain.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def all
    @wanted_domains = WantedDomain.all.order(:id)
  end

  def check_all
    WantedDomain.queue_all_unchecked

    flash[:notice] = 'All unchecked domains have been requeued.'
    redirect_to wanted_domains_all_path
  end

  private

  def wanted_domain_params
    params.require(:wanted_domain).permit(:name)
  end
end
