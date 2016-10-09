# To update cron jobs run below:
# whenever --write-crontab --set environment='development'
# crontab -l

## Drop Check cron jobs

every 1.day, at: '8:28 pm' do
  rake 'drop_check:prepare', environment: 'development', output: './log/drop_check_worker.log'
end

every 1.day, at: '8:29 pm' do
  rake 'drop_check:purchase_domain', environment: 'development', output: './log/purchase_domain_worker.log'
end

## Competitor Domains cron jobs

every 1.day, at: '7:00 am' do
  rake 'competitor_domains:park_io_check_sold', environment: 'development', output: './log/park_io_sold_csv_worker.log'
end

every 1.day, at: '9:00 pm' do
  rake 'competitor_domains:park_io_check_sold', environment: 'development', output: './log/park_io_sold_csv_worker.log'
end

every 1.day, at: '7:05 am' do
  rake 'competitor_domains:park_io_check_auctions', environment: 'development', output: './log/park_io_auction_api_worker.log'
end

every 1.day, at: '9:05 pm' do
  rake 'competitor_domains:park_io_check_auctions', environment: 'development', output: './log/park_io_auction_api_worker.log'
end

## Wanted Domains cron jobs

every 1.day, at: '8:35 pm' do
  rake 'wanted_domains:check_nic_io_domains_released_today', environment: 'development', output: './log/nic_io_released_today_scraper_worker.log'
end

every 1.day, at: '12:00 am' do
  rake 'wanted_domains:check_expired_domains_for_pending_delete', environment: 'development', output: './log/expired_domains_pending_delete_scraper_worker.log'
end

every 1.day, at: '12:10 am' do
  rake 'wanted_domains:check_expired_domains_for_deleted', environment: 'development', output: './log/expired_domains_deleted_scraper_worker.log'
end
