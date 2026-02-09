FROM ruby:3.2-alpine

RUN apk add --no-cache build-base postgresql-dev postgresql-client libpq

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

COPY . .
RUN chmod +x /app/bin/docker-entrypoint

EXPOSE 3000

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "config.ru", "-p", "3000"]
