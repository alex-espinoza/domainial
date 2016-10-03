# Domanial

Helper application for owned domain name organization.

## To run

`gem install foreman`
`bundle install`
`foreman start`


FEATURES TO ADD:

- create script that reads from park IO API (http://blog.park.io/articles/park-io-api/) and adds domains that are currenty being auctioned - PARK IO SPY
- create script that reads and saves park IOs last 50 sales (http://park.io/faq/ - end of page) - PARK IO SPY
- install whenever to cronjob certain workers
- change code to not save "." for tld
- add button to re-check domain


PLAN TO HOST CHEAPLY AND WITHOUT RUNNING EVERYONE LOCALLY:

- host main app on heroku
- main app connects to RDS to use for PostgresDB
- remove dictionary table and create separate app for it that communicates with main app via json API to queue wanted domains
- use AWS Lambda to schedule curl get request on app to wake it up before specific times it needs to run scheduled tasks
  - https://github.com/lorennorman/ruby-on-lambda
  - http://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html
  - http://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html (might just use javascript for the request)
