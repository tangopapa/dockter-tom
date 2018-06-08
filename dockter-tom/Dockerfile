FROM debian:stretch-slim
LABEL maintainer="tom@frogtownroad.com"

## Install Ruby and other OS stuff + nmap
RUN apt-get update  && \
apt-get install -y --no-install-recommends wget ruby mono-runtime  && \
rm -rf /var/lib/apt/lists/*
RUN apt-get install --no-install-recommends -y build-essential \
      bzip2 \
      unzip \
      ca-certificates \
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
      ruby-bundler && \
      rm -rf /var/lib/apt/lists/*

## Install Gauntlt --  Cucumber/gherkin framework with some reporting capability
RUN gem install ffi -v 1.9.18
RUN gem install gauntlt --no-rdoc --no-ri
RUN gem install bundle-audit 
RUN gem cleanup

## ---- Install Scan tools ----
## ---- Static Code Analysis ----

## Install Brakeman - ruby-on-rails SAST tool w/ Threadfix integration
## Usage: brakeman -q /path/to/application -o output.json -o output
RUN gem install brakeman

## Install OWASP Dependency Check -- Dependency-Check is a utility that attempts to detect 
## publicly disclosed vulnerabilities contained within project dependencies. 
## It does this by determining if there is a Common Platform Enumeration (CPE) identifier for a given dependency. 
## If found, it will generate a report linking to the associated CVE entries.
## Usage:  As Sonarqube plugin???
ENV version_url=https://jeremylong.github.io/DependencyCheck/current.txt
ENV download_url=https://dl.bintray.com/jeremy-long/owasp 

RUN wget -O /tmp/current.txt ${version_url}         && \                         
version=$(cat /tmp/current.txt)                     && \                               
file="dependency-check-${version}-release.zip"      && \                    
wget "$download_url/$file"                          && \                     
unzip ${file}                                       && \                    
rm -f ${file}                                       && \                           
mkdir -p /opt/depcheck                              && \                           
mv dependency-check /opt/depcheck                   && \                    
chown -R ${user}:${user} /opt/depcheck/dependency-check   && \              
mkdir -p /opt/depcheck/report                       && \                     
chown -R ${user}:${user} /opt/depcheck/report       && \                                 
apt-get autoremove -y                               && \                    
rm -rf /var/lib/apt/lists/* /tmp/*                  
 
## USER ${user}
## VOLUME ["/opt/depcheck" "opt/depcheck/dependency-check/data" "/report"]
## WORKDIR /opt/depcheck
## RUN /opt/depcheck/dependency-check/bin/dependency-check.sh


## ---- Dynamic Code Analysis  ----

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
WORKDIR /opt
ENV SQLMAP_PATH /opt/sqlmap/sqlmap.py
RUN git clone --depth=1 https://github.com/sqlmapproject/sqlmap.git


## Install dirb -- DIRB is a Web Content Scanner
## Usage: ./dirb <url_base> [<wordlist_file(s)>] [options]
RUN wget https://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz    && \
    tar xvfz dirb222.tar.gz                                                         && \
    cd dirb222                                                                      && \
    chmod 755 ./configure                                                           && \
    ./configure                                                                     && \
    make                                                                            && \
    ln -s /opt/dirb222/dirb /usr/local/bin/dirb
# ENV DIRB_WORDLISTS /opt/dirb222/wordlists

## Install nmap  -- Network exploration tool and security port scanner -- changed to added during main apt package pull
## Usage: nmap [ <Scan Type> ...] [ <Options> ] { <target specification> }

### To do's -----------------

#ENV user=dockter-tom
#RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user}
 
##  Install reporting tools

##  Connect to elk containher
##  docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk <repo-user>/elk
##  Install certificates

COPY docker-entrypoint.sh /usr/local/bin 
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh
CMD ["docker-entrypoint.sh"]

VOLUME ["/opt"]