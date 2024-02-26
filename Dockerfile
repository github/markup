FROM ubuntu:focal

RUN apt-get update -qq
RUN apt-get install -y apt-transport-https

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61
RUN echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs `lsb_release -cs` main" | tee -a /etc/apt/sources.list.d/rakudo-pkg.list
RUN apt-get update -qq

RUN apt-get install -y \
    perl rakudo-pkg curl git build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libicu-dev cmake pkg-config

# Add the deadsnakes PPA to get Python 3.11 and install it
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11
RUN pip install python3-docutils

ENV PATH $PATH:/opt/rakudo-pkg/bin
RUN install-zef-as-user && zef install Pod::To::HTML

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --installdeps --notest Pod::Simple

ENV PATH $PATH:/root/.rbenv/bin:/root/.rbenv/shims
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
RUN rbenv install 2.4.1
RUN rbenv global 2.4.1
RUN rbenv rehash

RUN gem install bundler

WORKDIR /data/github-markup
COPY github-markup.gemspec .
COPY Gemfile .
COPY Gemfile.lock .
COPY lib/github-markup.rb lib/github-markup.rb
RUN bundle

ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
