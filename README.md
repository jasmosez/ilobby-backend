# README

## OVERVIEW
iLobby is a tool to explore, select and take action towards state-level legislators in the United States.

This backend is an API that pulls data from the openstates.org api
The frontend can be found here: https://github.com/jasmosez/ilobby-frontend
It visualizes legislative districts using the google maps javascript api

You will need your own API keys for both.


## Ruby/Rails versions
Uses Ruby 2.6.1 and Rails 6.0.2.2

## Configuration
create an .env file in the root directory defining `OS_KEY` as your open states API key

## Database creation
Migrate and seed the database

Note that /db/seeds.rb contains, but does not use some methods for parsing collections of legislator twitter handles. To date those are being collected and processed in an ad hoc fashion.

## How to run the test suite
There is not test coverage at this time

## Current Deployment(s)
It is currently deployed at https://ilobby.thisjames.com

# Let me know what you think!
