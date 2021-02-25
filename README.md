# README

## OVERVIEW
iLobby is a tool to explore, select and take action towards state-level legislators in the United States.

This backend is an API that pulls data from the openstates.org API.

The frontend can be found here: https://github.com/jasmosez/ilobby-frontend. It visualizes legislative districts using the Google Maps Javascript API.

You will need your own API keys for both.

## Ruby/Rails versions
Uses Ruby 2.6.1 and Rails 6.0.2.2

To start a backend locally:
```
rails s
```

## Configuration
create an `.env` file in the root directory defining `OS_KEY` as your open states API key

## Database creation
### Migrate the database
```
rails db:migrate
```

### Seed the database
```
rails db:seed
```

Note that /db/seeds.rb contains, but does not use some methods for parsing collections of legislator twitter handles and exporting user data as csv files. To date this is all being done in an ad hoc fashion.

## How to run the test suite
There is not test coverage at this time

## Current Deployment(s)
The backend is currently deployed at https://ilobby-backend.herokuapp.com
The frontend is currently deployed at https://ilobby.thisjames.com

## Firebase & Firebase Id Token
The app uses Firebase to manage and validate users. The frontend login and signup components, run a complete auth flow with Firebase and then store a token in localStorage until the user logs out. This token is included in all fetches for user data (in an Authorization header) and validated by Firebase each time.

Token validation makes use of [Firebase Id Token](https://github.com/fschuindt/firebase_id_token). As per their documentation, this app requires a small Redis instance to store Google's x509 certificates. 

## Redis

To start a Redis server locally:
```
redis-server --port 6380
```

# Let me know what you think!
Feel free to browse the [iLobby project Trello board](https://trello.com/b/9C6jGF7k/ilobby) as well
