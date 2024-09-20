# Use the official Ruby image as the base image
FROM ruby:3.2.2-bookworm

# Install dependencies
RUN apt-get update -qq && apt-get install -y cimg-dev build-essential autoconf libtool imagemagick libjpeg-dev libpng-dev && apt-get install -y nodejs npm && npm install --global yarn

# Set the working directory inside the container
WORKDIR /usr/src

RUN wget http://sphinxsearch.com/files/sphinx-2.2.11-release.tar.gz
RUN tar -zxvf sphinx-2.2.11-release.tar.gz
RUN cd sphinx-2.2.11-release && ./configure --with-mysql && make && make install
# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile* /usr/src/
COPY .dev_conf/phashion-1.2.1.gem /usr/src/.dev_conf/
RUN ls /usr/src/.dev_conf/ # This line is just for debugging

# Install Ruby dependencies
RUN gem install bundler
RUN gem update bundler:3.5.6
RUN gem install /usr/src/.dev_conf/phashion-1.2.1.gem --local
RUN  bundle config set local.phashion /usr/local/bundle/gems/phashion-1.2.1
RUN bundle config build.phashion --build=aarch64-unknown-linux-gnu
RUN bundle install

# Copy the main application
COPY . /usr/src/app

# Add a script to be executed every time the container starts
COPY .dev_conf/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose the port the app runs on
EXPOSE 3000

# Start the main process (Rails server in this case)
CMD ["rails", "server", "-b", "0.0.0.0"]

