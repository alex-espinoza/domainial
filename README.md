# Domanial

Helper application for owned domain name organization.

## To run

`gem install foreman`
`bundle install`
`foreman start`

## FEATURES TO ADD:

- change code to not save "." for tld
- add button to re-check domain
- add schema constraints to CompetitorDomain
- create views to show competitor domain data
- start handling and checking .to domains

## PLAN TO HOST CHEAPLY AND WITHOUT RUNNING EVERYONE LOCALLY:

- host main app on heroku
- main app connects to RDS to use for PostgresDB
- remove dictionary table and create separate app for it that communicates with main app via json API to queue wanted domains
- use AWS Lambda to schedule curl get request on app to wake it up before specific times it needs to run scheduled tasks
  - https://github.com/lorennorman/ruby-on-lambda
  - http://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html
  - http://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html (might just use javascript for the request)

## IDEA FOR RUNNING MULTIPLE PURCHASE BOTS

- use AWS Lambda to run the standalone ruby script to purchase domain, run at specific time

## IMPORTANT TIMES:

8:30 PM EST 0:30 UTC daily - .io domains are expired

check millisecond time with `Model.find(1).created_at.strftime('%Y-%m-%d %H:%M:%S.%N')`

##8/3 EST MONDAY - 8/4 UTC 0:30 MONDAY EST DROP
LATEST TIME WHEN A DOMAIN WAS MARKED AS TAKEN: 30 min 12 seconds .430265000 milliseconds "resv.io" id: 55
EARLIEST TIME WHEN A DOMAIN WAS MARKED AS AVAILABLE: 30 min 14 seconds .000004000 milliseconds "pushbutton.io" id: 56
ANOTHER EARLY TIME: 30 min 14 seconds .160707000 milliseconds "socketio" id: 57
EARLIEST TIME WHEN DROP.IO SEEMS TO BE ABLE TO REGISTER: 30 min 15 seconds .872203000 milliseconds "tencent.io" id: 58 - ALREADY BACKORDERED
OTHER INTERESTING TIMES: 30 min 30 seconds "ade.io" id: 63 - PARK.IO PICKUP
TOTAL DROPPED DOMAINS: 70
SUCCESSFUL TOTAL CATCH: 0
FAILED TOTAL CATCH: 1

##8/4 EST MONDAY - 8/5 UTC 0:30 TUESDAY EST DROP
EARLIEST TIME WHEN A DOMAIN WAS MARKED AS AVAILABLE: 30 min 15 seconds .357101 milliseconds id: 466
TOTAL DROPPED DOMAINS: 111
SUCCESFUL TOTAL CATCH: 0
FAILED TOTAL CATCH: 1

- Notes
Attempt 0 2016-10-04 20:30:14.000050000
Attempt 1 2016-10-04 20:30:21.764378000
^ drop log indicates there was a 7+ second wait between these two purchase attempts. may indicate server processed my request first,
but i didn't have enough funds to make a successful transaction. perhaps 30 min 14 sec is the sweet spot, but lets try 30 min 13 secs or 30 min 13.5 secs
