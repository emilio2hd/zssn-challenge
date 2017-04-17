FROM ruby:2.3.1-slim

RUN mkdir /zssn \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libpq-dev zlib1g-dev liblzma-dev netcat libsqlite3-dev build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /zssn
ADD . /zssn
EXPOSE 3000

ENV RAILS_ENV=production

RUN gem install bundler && bundle install --without development test

CMD ["bash", "init.sh"]
