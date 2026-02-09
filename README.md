# ShortLink Engine

A URL shortening service built with **Ruby on Rails**. Submit a long URL and get a short link; submit the short link to get back the original URL. All state is stored in the database so encoded URLs survive restarts.

## Features

- **POST /encode** — Encodes a URL to a shortened URL (JSON in/out).
- **POST /decode** — Decodes a shortened URL to the original URL (JSON in/out).
- **Idempotent encode** — Encoding the same URL again returns the same short URL.
- **Persistence** — Short URLs are stored in the database and work after restarts.

## Quick start

See **[RUNNING.md](RUNNING.md)** for:

- Prerequisites and setup
- Creating the database and running migrations
- Starting the server
- Running tests
- Example API requests (curl)

## Security considerations (attack vectors)

The following risks were considered and are documented; mitigations are in place where feasible for this scope.

1. **Open redirect / malicious target URLs**  
   - **Risk:** Short links could point to phishing or malicious sites.  
   - **Mitigation:** URLs are normalized and stored as-is; we do not redirect on decode. This service only returns the original URL in JSON. If you later add HTTP redirects from short URLs, validate the target (e.g. blocklist, allowlist, or redirect warning page).

2. **Abuse / spam**  
   - **Risk:** High volume of encodes to flood the database or create many links to bad URLs.  
   - **Mitigation:** Not implemented in this demo. For production: rate limiting (e.g. Rack::Attack), CAPTCHA, or authentication would help.

3. **Enumeration of short codes**  
   - **Risk:** Short codes are guessable (e.g. 6-character alphanumeric); clients could probe for valid codes.  
   - **Mitigation:** Codes are random (not sequential). For production: stricter rate limiting on decode and monitoring for bulk decoding would reduce impact.

4. **Injection (XSS / open redirect in API responses)**  
   - **Risk:** If URLs were rendered in a browser without escaping, stored URLs could contain script or redirect payloads.  
   - **Mitigation:** This is a JSON API; clients must treat `original_url` and `short_url` as data and escape when rendering in HTML. No HTML is rendered by the service.

5. **SQL injection**  
   - **Risk:** User input used in raw SQL could lead to injection.  
   - **Mitigation:** ActiveRecord is used with parameterized queries; no raw SQL is built from user input.

6. **Information disclosure**  
   - **Risk:** Verbose errors could leak stack traces or internals.  
   - **Mitigation:** In production, disable detailed error pages and log errors server-side only.

Implementing rate limiting, authentication, and redirect policies is recommended before exposing the service publicly.

## Scalability and collision handling

- **Collision problem**  
  Short codes are random (6 characters, base62). Collisions are possible; the implementation retries with a new random code up to a fixed number of times. For a single process and moderate volume this is sufficient. For very high throughput, see below.

- **Scaling encode throughput**  
  - **Option A (recommended for scaling):** Use a **monotonically increasing ID** (e.g. DB sequence or Redis INCR) and encode the number in base62 to get the short code. No collision by design; ordering is preserved.  
  - **Option B:** Keep random codes but make the code longer (e.g. 8–10 characters) to reduce collision probability, and use a unique index + retry (or “insert and catch unique violation”) in the database when a collision occurs.

- **Scaling decode (reads)**  
  Decode is a lookup by `short_code` (unique index). It scales with read replicas, caching (e.g. Redis in front of DB), and connection pooling. No application-level change required beyond infrastructure.

- **Idempotent encode**  
  “Same long URL → same short URL” is implemented by checking `original_url` (with an index) before creating a new row. At scale, this can be moved to a cache (e.g. Redis) keyed by normalized URL to reduce DB load.

- **Database**  
  SQLite is fine for a demo. For production, use PostgreSQL or MySQL with appropriate connection pooling and backups.

This codebase is intended as a demo and does not implement the above scaling measures; the README documents how you would approach them.

## License

MIT (or your chosen license).
