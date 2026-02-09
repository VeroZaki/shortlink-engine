# ShortLink Engine — Architecture

## High-level overview

```mermaid
flowchart TB
    subgraph Client
        A[Client / API consumer]
    end

    subgraph Rails["Rails API"]
        B[Routes]
        C[ShortLinksController]
        B --> C
    end

    subgraph App["Application layer"]
        D[ShortUrl model]
        E[UrlNormalizer]
        F[UrlValidator]
        G[Base62Validator]
        C --> D
        D --> E
        D --> F
        D --> G
    end

    subgraph Data["Data layer"]
        H[(PostgreSQL)]
        D --> H
    end

    A -->|POST /encode, POST /decode| B
```

## Request flow

### Encode (URL → short URL)

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Model
    participant Validators
    participant DB

    Client->>Controller: POST /encode { url }
    Controller->>Model: ShortUrl.encode_url(url)
    Model->>Model: UrlNormalizer.normalize(url)
    alt invalid URL
        Model-->>Controller: nil
        Controller-->>Client: 422 Invalid URL
    else valid URL
        Model->>DB: find_by(original_url) or new + save
        DB->>Model: record
        Model->>Validators: presence, url, base62, uniqueness
        Validators-->>Model: valid
        Model-->>Controller: ShortUrl record
        Controller-->>Client: 201 { short_url, original_url }
    end
```

### Decode (short URL → original URL)

```mermaid
sequenceDiagram
    participant Client
    participant Controller
    participant Model
    participant DB

    Client->>Controller: POST /decode { short_url }
    Controller->>Model: ShortUrl.decode_to_original(short_url)
    Model->>Model: extract_short_code(short_url)
    Model->>DB: find_by(short_code: code)
    alt not found
        DB-->>Model: nil
        Model-->>Controller: nil
        Controller-->>Client: 404
    else found
        DB-->>Model: ShortUrl
        Model-->>Controller: original_url
        Controller-->>Client: 200 { original_url }
    end
```

## Component map

| Layer        | Component            | Responsibility                                      |
|-------------|----------------------|-----------------------------------------------------|
| **HTTP**    | Routes               | POST /encode, POST /decode → ShortLinksController   |
| **Controller** | ShortLinksController | Params, call model, JSON response, error handling    |
| **Model**   | ShortUrl             | encode_url, decode_to_original, normalize_url, DB   |
| **Validators** | UrlValidator      | original_url must be valid (HTTP/HTTPS, no js/data)  |
| **Validators** | Base62Validator   | short_code: base62 only, length 6                  |
| **Lib**     | UrlNormalizer       | Normalize and validate URL format                   |
| **Data**    | PostgreSQL           | short_urls (original_url, short_code)               |

## Data model

```mermaid
erDiagram
    short_urls {
        bigint id PK
        string original_url "NOT NULL, indexed"
        string short_code "NOT NULL, unique indexed"
        datetime created_at
        datetime updated_at
    }
```

## File layout

```
shortlink-engine/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── short_links_controller.rb   # encode, decode
│   ├── models/
│   │   └── short_url.rb
│   └── validators/
│       ├── url_validator.rb
│       └── base62_validator.rb
├── config/
│   ├── routes.rb                      # /encode, /decode
│   └── database.yml                   # PostgreSQL
├── lib/
│   └── url_normalizer.rb
├── db/
│   └── migrate/
│       └── 001_create_short_urls.rb
└── docs/
    └── ARCHITECTURE.md                 # this file
```
