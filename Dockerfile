FROM ruby:2.3.1
RUN apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y \
    build-essential libpq-dev libxml2-dev libxslt1-dev \
    libfontconfig1 libfontconfig1-dev && \
  apt-get clean

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV PHANTOM_JS phantomjs-2.1.1-linux-x86_64

RUN tar xvjf bin/$PHANTOM_JS.tar.bz2 && \
  mv $PHANTOM_JS /usr/local/share && \
  ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /bin/phantomjs && \
  rm bin/$PHANTOM_JS.tar.bz2
