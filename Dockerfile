# Use the official Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:3.3

# Install production dependencies.
WORKDIR /app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN=true
RUN gem install --no-document bundler \
  && bundle config --local frozen true \
  && bundle config --local without "development test" \
  && bundle install

# Copy local code to the container image.
COPY . ./

EXPOSE 8080
ENV PORT=8080

# Run the web service on container startup.
ENTRYPOINT ["bundle", "exec", "functions-framework-ruby"]
CMD ["--target", "app", "--port", "8080", "--source", "lib/main.rb"]