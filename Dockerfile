FROM ubuntu:focal

RUN apt-get update -qq
RUN apt-get install -y apt-transport-https

RUN apt-get install -y \
    locales \
    software-properties-common \
    curl \
    gnupg2

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0DD4CA7EB1C6CC6B
RUN curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.deb.txt?distro=ubuntu&codename=lunar&component=main' > /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list
RUN apt-get update -qq

RUN apt-get install -y \
    perl rakudo-pkg curl git build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libicu-dev cmake pkg-config

ENV PATH $PATH:/opt/rakudo-pkg/bin
RUN install-zef-as-user && zef install Pod::To::HTML

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --installdeps --notest Pod::Simple

ENV PATH $PATH:/root/.rbenv/bin:/root/.rbenv/shims
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
RUN rbenv install 3.3.0
RUN rbenv global 3.3.0
RUN rbenv rehash

RUN gem install bundler

WORKDIR /data/github-markup
COPY github-markup.gemspec .
COPY Gemfile .
COPY lib/github-markup.rb lib/github-markup.rb
RUN bundle

ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
