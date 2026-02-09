# How to Run ShortLink

## Prerequisites

- **Ruby 3.0+** (project uses `.ruby-version` 3.2.4; e.g. `rbenv install 3.2.4` if you use rbenv)
- **Bundler**: `gem install bundler`
- **PostgreSQL** installed and running (see below)

### Starting PostgreSQL (macOS with Homebrew)

If you see `Connection refused` on port 5432, start the server:

```bash
brew services start postgresql
```

If PostgreSQL isn’t installed:

```bash
brew install postgresql
brew services start postgresql
```

Wait a few seconds, then run `rake db:create` and `rake db:migrate`.

**Check that PostgreSQL is running:**

```bash
brew services list    # postgresql should show "started"
pg_isready -h localhost   # should print "accepting connections"
```

If you get authentication errors, try your macOS username (Homebrew often uses it instead of `postgres`):

```bash
export PGUSER=$(whoami)
bundle exec rake db:create
bundle exec rake db:migrate
```

## Setup

1. **Install dependencies**

   ```bash
   cd shortlink-engine
   bundle install
   ```

2. **Set up environment (optional)**

   Copy the example env file and edit as needed. The app will use these values in development/test:

   ```bash
   cp .env.example .env
   # Edit .env to set PGUSER, PGPASSWORD, PGHOST, SHORTLINK_BASE_URL, etc.
   ```

3. **Create and migrate the database**

   Ensure PostgreSQL is running, then:

   ```bash
   bundle exec rake db:create
   bundle exec rake db:migrate
   ```

   By default the app uses user `postgres`, no password, and host `localhost`. Set these in `.env` or export:

   ```bash
   export PGUSER=your_user
   export PGPASSWORD=your_password
   export PGHOST=localhost
   ```

4. **(Optional) Set the base URL for short links**

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

The app uses **PostgreSQL**. Databases:

- `shortlink_engine_development` (development)
- `shortlink_engine_test` (test)
- `shortlink_engine_production` (production)

Set `PGUSER`, `PGPASSWORD`, and `PGHOST` in production (or use a URL in `config/database.yml` if you prefer).
