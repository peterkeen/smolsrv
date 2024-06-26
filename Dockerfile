FROM ruby:3-alpine as build-env

ARG APP_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="yaml-dev zlib-dev nodejs"
ARG RUBY_PACKAGES="tzdata"
ENV RACK_ENV=production
WORKDIR $APP_ROOT

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES

COPY Gemfile* ./
COPY Gemfile Gemfile.lock $APP_ROOT/

RUN bundle config --global frozen 1 \
    && bundle install --without development:test:assets -j4 --retry 3 \
    && bundle binstubs puma \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf /usr/local/bundle/ruby/3.2.0/cache/*.gem

COPY . .

#######

FROM ruby:3-alpine
ARG APP_ROOT=/app
ARG PACKAGES="tzdata bash"
ENV RACK_ENV=production

WORKDIR $APP_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

ENV PATH=$APP_ROOT/bin:/usr/local/bin:/usr/bin:/bin

COPY --from=build-env $APP_ROOT $APP_ROOT
COPY --from=build-env /usr/local/bundle /usr/local/bundle
CMD ["bundle", "exec", "rackup"]