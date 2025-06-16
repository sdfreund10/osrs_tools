# Use the official Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:3.3

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install bundler && bundle config set --local without 'test'

# Copy local code to the container image.
COPY . ./
RUN bundle install

EXPOSE 4567

# Run the web service on container startup.
CMD ["ruby", "lib/app.rb"]