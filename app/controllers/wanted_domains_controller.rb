class WantedDomainsController < ApplicationController
  def index
    todays_io_drop_time = WantedDomain.io_drop_time
    tomorrows_io_drop_time = todays_io_drop_time + 1.day

    if Time.now.utc < todays_io_drop_time
      @io_domains_being_released_in_next_day = WantedDomain.where(tld: 'io', grace_period_ends_date: todays_io_drop_time, status_code: 0).order(:name)
    else
      @io_domains_being_released_in_next_day = WantedDomain.where(tld: 'io', grace_period_ends_date: tomorrows_io_drop_time, status_code: 0).order(:name)
    end

    @to_domains_being_released_in_next_day = WantedDomain.where(tld: 'to', grace_period_ends_date: Time.now.utc.beginning_of_day..Time.now.utc.end_of_day, status_code: 0).order(:grace_period_ends_date)
  end

  def show
    @wanted_domain = WantedDomain.find(params[:id])
  end

  def new
    @wanted_domain = WantedDomain.new
    @tlds = WantedDomain::SUPPORTED_TLDS
  end

  def create
    @wanted_domain = WantedDomain.new(wanted_domain_params)
    @wanted_domain.name = @wanted_domain.name.strip.downcase
    @wanted_domain.tld = @wanted_domain.tld.strip.downcase

    if @wanted_domain.valid? && @wanted_domain.save
      WantedDomainCheckEnqueuer.queue(@wanted_domain.tld, @wanted_domain.id)
      flash[:success] = "#{@wanted_domain.name_with_tld} added."
      redirect_to wanted_domains_all_path
    else
      @tlds = WantedDomain::SUPPORTED_TLDS
      flash.now[:error] = @wanted_domain.errors.full_messages.to_sentence
      render action: 'new'
    end
  end

  def expiring_within_month
    todays_io_drop_time = WantedDomain.io_drop_time
    one_month_drop_time = todays_io_drop_time + 30.days
    @domains_being_released_in_month = WantedDomain.where(grace_period_ends_date: todays_io_drop_time..one_month_drop_time, status_code: 0).order(:grace_period_ends_date)
  end

  def interested
    @interested_domains = WantedDomain.where(interested?: 1).order(:grace_period_ends_date)
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
    params.require(:wanted_domain).permit(:name, :tld)
  end
end
