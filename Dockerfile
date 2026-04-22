FROM ubuntu:trusty@sha256:64483f3496c1373bfd55348e88694d1c4d0c9b660dee6bfef5e12f43b9933b30 # trusty

RUN apt-get update -qq
RUN apt-get install -y apt-transport-https

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61
RUN echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs `lsb_release -cs` main" | tee -a /etc/apt/sources.list.d/rakudo-pkg.list
RUN apt-get update -qq

RUN apt-get install -y \
    perl rakudo-pkg curl git build-essential python python-pip \
    libssl-dev libreadline-dev zlib1g-dev \
    libicu-dev cmake pkg-config

ENV PATH $PATH:/opt/rakudo-pkg/bin
RUN install-zef-as-user && zef install Pod::To::HTML

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --installdeps --notest Pod::Simple

RUN echo 'docutils==0.22.4 --hash=sha256:d0013f540772d1420576855455d050a2180186c91c15779301ac2ccb3eeb68de' > /tmp/requirements.txt && \
    pip install -r /tmp/requirements.txt

ENV PATH $PATH:/root/.rbenv/bin:/root/.rbenv/shims
RUN curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
RUN rbenv install 2.4.1
RUN rbenv global 2.4.1
RUN rbenv rehash

RUN gem install bundler -v 2.4.10

WORKDIR /data/github-markup
COPY github-markup.gemspec .
COPY Gemfile .
COPY Gemfile.lock .
COPY lib/github-markup.rb lib/github-markup.rb
RUN bundle

ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
