class WantedDomainsController < ApplicationController
  def index
    todays_io_drop_time = Time.now.utc.beginning_of_day + 30.minutes
    tomorrows_io_drop_time = todays_io_drop_time + 1.day

    if Time.now.utc < todays_io_drop_time
      @domains_being_released_in_next_day = WantedDomain.where(grace_period_ends_date: todays_io_drop_time, status_code: 0).order(:name)
    else
      @domains_being_released_in_next_day = WantedDomain.where(grace_period_ends_date: tomorrows_io_drop_time, status_code: 0).order(:name)
    end
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
    todays_io_drop_time = Time.now.utc.beginning_of_day + 30.minutes
    one_month_drop_time = todays_io_drop_time + 30.days
    @domains_being_released_in_month = WantedDomain.where(grace_period_ends_date: todays_io_drop_time..one_month_drop_time, status_code: 0).order(:grace_period_ends_date)
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
