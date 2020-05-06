FROM ubuntu:trusty

RUN apt-get update -qq
RUN apt-get install -y apt-transport-https

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61
RUN echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs `lsb_release -cs` main" | tee -a /etc/apt/sources.list.d/rakudo-pkg.list
RUN apt-get update -qq

RUN apt-get install -y \
    perl rakudo-pkg curl git build-essential python python-pip \
    libssl-dev libreadline-dev zlib1g-dev \
    libicu-dev cmake3 pkg-config


#####################################
# npm, nvm & yarn:
#####################################

# nvm environment variables
ENV NVM_DIR /usr/local/nvm
# latest LTS version
ENV NODE_VERSION 12.16.1
# node
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash

ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
RUN npm install -g pod6@0.0.20


ENV PATH $PATH:/opt/rakudo-pkg/bin
RUN install-zef-as-user && zef install Pod::To::HTML

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --installdeps --notest Pod::Simple

RUN pip install docutils

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
