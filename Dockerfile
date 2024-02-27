FROM ubuntu:focal

RUN apt-get update -qq
RUN apt-get install -y \
    apt-transport-https \
    locales \
    software-properties-common \
    curl \
    gnupg2

# add the Raku repository
RUN curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/gpg.0DD4CA7EB1C6CC6B.key' |  gpg --dearmor >> /usr/share/keyrings/nxadm-pkgs-rakudo-pkg-archive-keyring.gpg
RUN curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/config.deb.txt?distro=ubuntu&codename=focal&component=main' > /etc/apt/sources.list.d/nxadm-pkgs-rakudo-pkg.list
# add the Node.js repository
RUN curl -1sLf https://deb.nodesource.com/setup_20.x | bash
RUN apt-get update -qq

RUN apt-get install -y \
    perl \
    rakudo-pkg \
    git \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libicu-dev \
    cmake \
    build-essential \
    g++ \
    pkg-config \
    nodejs \
    libffi-dev \
    libyaml-dev \
    gcc \
    libxslt-dev \
    libxml2-dev \
    zlib1g-dev

ENV PATH $PATH:/opt/rakudo-pkg/bin
RUN install-zef
ENV PATH $PATH:/root/.raku/bin
RUN zef install Pod::To::HTML2

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm --installdeps --notest Pod::Simple

# Install Rbenv and Ruby
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && echo 'eval "$(rbenv init -)"' >> ~/.bashrc
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
ENV PATH $PATH:/root/.rbenv/bin:/root/.rbenv/shims
RUN cd /root/.rbenv/plugins/ruby-build && git pull && cd -
ENV RUBY_VERSION 3.3.0
RUN rbenv install $RUBY_VERSION && rbenv global $RUBY_VERSION && rbenv rehash
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN gem install bundler:2.4.22
RUN gem install nokogiri --platform=ruby -- --use-system-libraries

WORKDIR /data/github-markup
COPY github-markup.gemspec .
COPY Gemfile .
COPY lib/github-markup.rb lib/github-markup.rb
RUN bundle

ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US.UTF-8
