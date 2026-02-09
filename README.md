# ShortLink Engine

Rails app that shortens URLs. Send it a long URL and get back a short one; send the short one and get the original. Everything is stored in Postgres so it survives restarts.

You get two endpoints: **POST /encode** and **POST /decode**, both JSON. Encoding the same URL twice returns the same short link. There’s a bit more on how it’s built in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

**To run it:** see [RUNNING.md](RUNNING.md) for setup, DB, and curl examples.

---

## Security

We’re not doing redirects here—decode just returns the original URL in JSON. A few things we did think about:

- **Malicious URLs** – We normalize and store whatever URL you give us. If you later add real redirects, you’ll want something (blocklist, allowlist, or a warning page) so you’re not redirecting to sketchy sites.
- **Abuse** – No rate limiting or auth in this demo. For production you’d add something like Rack::Attack or require auth.
- **Short codes** – They’re random and 6 chars, so they’re guessable in theory. Again, rate limiting and monitoring help if you care.
- **XSS** – It’s a JSON API. Don’t dump the response into HTML without escaping.
- **SQL** – We use ActiveRecord; no raw SQL from user input.
- **Errors** – In production, turn off fancy error pages and log on the server so you’re not leaking stack traces.

---

## Scaling (if you ever need it)

Right now we generate random base62 codes and retry on collision. Fine for one process and normal traffic. If you need more:

- **Encode:** Use a monotonic ID (DB sequence or Redis INCR), turn it into base62, and you’re done—no collisions. Or keep random but longer codes and rely on the unique index + retry.
- **Decode:** It’s a lookup by `short_code`. Scale with read replicas, Redis in front, connection pooling—no app changes.
- **Same URL → same short link** is done by looking up `original_url` before creating. At scale you could cache that in Redis keyed by the normalized URL.

Postgres is the only store. Use pooling and backups when you go to production.
