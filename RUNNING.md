# How to Run ShortLink

## Prerequisites

- **Ruby 3.0+** (project uses `.ruby-version` 3.2.4; e.g. `rbenv install 3.2.4` if you use rbenv)
- **Bundler**: `gem install bundler`

## Setup

1. **Install dependencies**

   ```bash
   cd shortlink-engine
   bundle install
   ```

2. **Create and migrate the database**

   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   ```

3. **(Optional) Set the base URL for short links**

   By default, short URLs use `http://localhost:3000`. To use your own domain:

   ```bash
   export SHORTLINK_BASE_URL="https://your.domain.com"
   ```

## Run the server

```bash
bundle exec puma config.ru
```

Or with Rack:

```bash
bundle exec rackup config.ru
```

The API will be available at **http://localhost:9292** (rackup) or **http://localhost:3000** (puma default). Puma’s port can be changed with `-p`, e.g.:

```bash
bundle exec puma config.ru -p 3000
```

## Run tests

```bash
bundle exec rake test
```

Or run a single test file:

```bash
bundle exec ruby -Itest test/integration/short_links_test.rb
```

## API usage

### Encode a URL

**Request**

- **Method:** `POST`
- **URL:** `/encode`
- **Content-Type:** `application/json`
- **Body:** `{ "url": "https://codesubmit.io/library/react" }`

**Example (curl)**

```bash
curl -X POST http://localhost:9292/encode \
  -H "Content-Type: application/json" \
  -d '{"url":"https://codesubmit.io/library/react"}'
```

**Example response (201 Created)**

```json
{
  "short_url": "http://localhost:9292/GeAi9K",
  "original_url": "https://codesubmit.io/library/react"
}
```

### Decode a short URL

**Request**

- **Method:** `POST`
- **URL:** `/decode`
- **Content-Type:** `application/json`
- **Body:** `{ "short_url": "http://localhost:9292/GeAi9K" }`

**Example (curl)**

```bash
curl -X POST http://localhost:9292/decode \
  -H "Content-Type: application/json" \
  -d '{"short_url":"http://localhost:9292/GeAi9K"}'
```

**Example response (200 OK)**

```json
{
  "original_url": "https://codesubmit.io/library/react"
}
```

## Database

The app uses **SQLite3** by default (development and test). Data is stored in:

- `db/development.sqlite3` (development)
- `db/test.sqlite3` (test)

To use **MySQL** or **PostgreSQL** in production, update `config/database.yml` and add the matching gem to the Gemfile, then run `bundle install` and migrations on the target environment.
