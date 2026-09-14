# Forecastly

Address autocomplete backed by Google Geocoding, and current weather conditions
for the selected place, cached for 30 minutes.

## Stack

- Ruby 3.2.2, Rails 7.1.6
- Redis as the cache store
- Hotwire (Turbo Frames + Stimulus)
- Tailwind CSS
- RSpec + WebMock, RuboCop

## Running

Everything runs in Docker. One step:

```sh
docker compose up
```

That starts Redis, the Rails web server and Tailwind watcher.

- App: <http://localhost:3000>
- Redis is exposed on host port **6380** (non-standard, so it won't collide)

## Tests and linting

```sh
docker compose run --rm web bundle exec rspec
docker compose run --rm web bundle exec rubocop
```

## Development process

- Thin controllers delegating to single-responsibility services

- I wanted right away to make it work by typing either a zip code or an address. I started using Nominatim API (https://nominatim.openstreetmap.org/) as the geocoding tool, but after some tests I noticed Google's Geocoding API would return more complete data. I decided to keep both client implementations so we can pull data from different providers through a normalized interface, swapping one does not affect the other.

- I chose Faraday because its JSON middleware delivers a parsed body automatically, so no call site parses JSON by hand, and because it keeps every API client small and identical in shape.

- For the weather I also used a Google service. Cache key uses `zip_code` when available, falls back to `place_id` for locations without postal codes (countries for example).

- SQLite is used as the database adapter since nothing is persisted.

- For linting I used `rubocop-rails-omakase`, the configuration the Rails team publishes, instead of RuboCop's defaults.

- For linting I used rubocop-rails-omakase, the configuration the Rails team publishes, instead of RuboCop's defaults.

- I had some trouble bringing the results from the controller into the Stimulus views, since it had been a while since I last worked with this pattern, but it is still simpler in this case than other alternatives.


### With more time I would

- Add rate limiting with the `rack-attack` gem to protect against abusive or bot requests.

- Order address suggestions by proximity to the user's current location.

- Upgrade to Rails 8 and leverage Solid Cache as the default cache backend.