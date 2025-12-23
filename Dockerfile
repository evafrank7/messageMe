# Use a Ruby version Rails 5.2 likes
FROM ruby:2.7.8

# System deps (node is needed for asset pipeline execjs)
RUN apt-get update -qq && apt-get install -y \
  nodejs \
  sqlite3 \
  libsqlite3-dev \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems first (better layer caching)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.22 && bundle install

# Copy the app
COPY . .

ENV RAILS_ENV=production
ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=true
ENV RAILS_SERVE_STATIC_FILES=true

# Precompile assets during build
RUN bundle exec rake assets:precompile

# Render expects your web service to bind on 0.0.0.0 and port 10000 by default
EXPOSE 10000
CMD ["bash", "-lc", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-10000}"]