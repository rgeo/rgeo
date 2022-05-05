FROM ruby:3.0

ARG work_dir=/ bundle_dir=/usr/local/bundle

WORKDIR ${work_dir}
# RUN bundle config set --local path ${bundle_dir}

RUN apt update && apt install -y libgeos-dev valgrind

COPY Gemfile rgeo.gemspec ./
COPY lib/rgeo/version.rb ./lib/rgeo/
RUN bundle install

COPY . .
RUN rake compile


CMD ["rake", "test:valgrind"]
