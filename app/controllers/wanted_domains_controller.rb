class WantedDomainsController < ApplicationController
  def index
    beginning_of_today = DateTime.now.utc.beginning_of_day
    beginning_of_tomorrow = beginning_of_today + 2.days
    @domains_being_released_in_48_hours = WantedDomain.where(grace_period_ends_date: beginning_of_today..beginning_of_tomorrow, status_code: 0).order(:grace_period_ends_date)
  end

  def show
    @wanted_domain = WantedDomain.find(params[:id])
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

  def expiring_within_month
    beginning_of_today = DateTime.now.utc.beginning_of_day
    one_month = beginning_of_today + 32.days
    @domains_being_released_in_month = WantedDomain.where(grace_period_ends_date: beginning_of_today..one_month, status_code: 0).order(:grace_period_ends_date)
  end

  def all
    @wanted_domains = WantedDomain.all.order(id: :desc)
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
