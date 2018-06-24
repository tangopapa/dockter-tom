FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

#ENV user=dockter-tom
#RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user}

## Install Ruby and other OS stuff + nmap
RUN apt-get update  && \
    apt-get install --no-install-recommends -y \
      supervisor \
      wget \
      ruby \
      build-essential \
      bzip2 \
      apt-transport-https \
      curl \
      gcc \
      git \
      libcurl3 \
      libcurl4-openssl-dev \
      zlib1g-dev \
      libfontconfig \
      libxml2-dev \
      libxslt1-dev \
      make \
      python-pip \
      python2.7 \
      python2.7-dev \
      ruby \
      ruby-dev \
      libtimedate-perl \
      libnet-ssleay-perl \
      nmap \
      unzip \
      ruby-bundler \
      ## troubleshooting
      tree && \  
      ## troubleshooting   
      rm -rf /var/lib/apt/lists/*

## Install Gauntlt --  Cucumber/gherkin framework with some reporting capability
RUN gem install ffi -v 1.9.18               && \
    gem install gauntlt --no-rdoc --no-ri   && \
    gem install bundle-audit                && \
    gem cleanup

## Add directory at ./**/*.attack_files relative to gauntlt executable
RUN mkdir -p /opt/attack                    
## Upload attack files to attack directory
COPY attacks/*.attack /opt/attack/

## ---- Install Scan tools ----
## ---- Static Code Analysis ----

## Install Brakeman - ruby-on-rails SAST tool w/ Threadfix integration
## Usage: brakeman -q /path/to/application -o output.json -o output
RUN gem install brakeman


## ---- Dynamic Code Analysis  ----

WORKDIR /opt

## Install Nikto2 -- Nikto2 is an Open Source (GPL) web server scanner 
## which performs comprehensive tests against web servers for multiple items
## Usage: perl nikto -h 192.168.0.1 -p 80,88,443
RUN git clone --depth=1 https://github.com/sullo/nikto.git      && \
    cd nikto/program                                            && \
    echo "EXECDIR=/opt/nikto/program" >> nikto.conf             && \
    ln -s /opt/nikto/program/nikto.conf /etc/nikto.conf         && \
    chmod +x nikto.pl                                           && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

## Install sqlmap -- sqlmap is an open source penetration testing tool 
## that automates the process of detecting and exploiting SQL injection flaws.
## Usage: python /opt/sqlmap/sqlmap.py [options]  -- https://github.com/sqlmapproject/sqlmap/wiki/Usage

RUN git clone --depth=1 https://github.com/sqlmapproject/sqlmap.git && \
chmod +x sqlmap/sqlmap.py && \
ln -s /opt/sqlmap/sqlmap.py /usr/local/bin/sqlmap



## Install dirb -- DIRB is a Web Content Scanner
## Usage: ./dirb <url_base> [<wordlist_file(s)>] [options]
RUN wget https://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz    && \
    tar xvfz dirb222.tar.gz                                                         && \
    cd dirb222                                                                      && \
    chmod 755 ./configure                                                           && \
    ./configure                                                                     && \
    make                                                                            && \
    ln -s /opt/dirb222/dirb /usr/local/bin/dirb                                     && \
    rm -rf dirb222.tar*
ENV DIRB_WORDLISTS /opt/dirb222/wordlists

## Install nmap  -- Network exploration tool and security port scanner -- changed to added during main apt package pull
## Usage: nmap [ <Scan Type> ...] [ <Options> ] { <target specification> }

### To do's -----------------

##  Install reporting tools

##  Connect to elk containher
##  docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk <repo-user>/elk
##  Install certificates

## Add supervisord.conf to startup executables
COPY ./supervisord.conf /opt/supervisord.conf

#COPY docker-entrypoint.sh /usr/local/bin 
#RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

#ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/bin/supervisord","--configuration=/opt/supervisord.conf"]


