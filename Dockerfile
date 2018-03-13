FROM debian:stretch-slim
MAINTAINER tom@frogtownroad.com
# Many thanks to guantlt-docker

ENV user=dockter-tom
RUN groupadd -r ${user} && useradd -r -l -M ${user} -g ${user} 

ARG ARACHNI_VERSION=arachni-1.5.1-0.5.12

# Install Ruby and other OS stuff
RUN apt-get update
RUN apt-get install -y --no-install-recommends wget ruby mono-runtime  
RUN apt-get install -y build-essential \
      bzip2 \
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
      ruby-bundler && \
      rm -rf /var/lib/apt/lists/*

# Install Gauntlt
RUN gem install ffi -v 1.9.18
RUN gem install gauntlt --no-rdoc --no-ri
RUN gem install bundle-audit 
RUN gem cleanup

# Install Attack tools
WORKDIR /opt

#  Static Code Analysis

# Install Brakeman - Ruby-on-rails SAST tool w/ Threadfix integration
# To run: brakeman -q /path/to/application -o output.json -o output
RUN gem install brakeman



# Dynamic Code Analysis

# Install Arachni
RUN wget https://github.com/Arachni/arachni/releases/download/v1.5.1/${ARACHNI_VERSION}-linux-x86_64.tar.gz && \
    tar xzvf ${ARACHNI_VERSION}-linux-x86_64.tar.gz && \
    mv ${ARACHNI_VERSION} /usr/local && \
    ln -s /usr/local/${ARACHNI_VERSION}/bin/* /usr/local/bin/

# Install Nikto
RUN apt-get update                                              && \
    apt-get install -y libtimedate-perl                            \
      libnet-ssleay-perl                                        && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/sullo/nikto.git      && \
    cd nikto/program                                            && \
    echo "EXECDIR=/opt/nikto/program" >> nikto.conf             && \
    ln -s /opt/nikto/program/nikto.conf /etc/nikto.conf         && \
    chmod +x nikto.pl                                           && \
    ln -s /opt/nikto/program/nikto.pl /usr/local/bin/nikto

# Install sqlmap
WORKDIR /opt
ENV SQLMAP_PATH /opt/sqlmap/sqlmap.py
RUN git clone --depth=1 https://github.com/sqlmapproject/sqlmap.git

# Install dirb
RUN wget https://downloads.sourceforge.net/project/dirb/dirb/2.22/dirb222.tar.gz    && \
    tar xvfz dirb222.tar.gz                                                         && \
    cd dirb222                                                                      && \
    chmod 755 ./configure                                                           && \
    ./configure                                                                     && \
    make                                                                            && \
    ln -s /opt/dirb222/dirb /usr/local/bin/dirb

ENV DIRB_WORDLISTS /opt/dirb222/wordlists

# Install nmap
RUN apt-get update                  && \
    apt-get install -y nmap         && \
    rm -rf /var/lib/apt/lists/*

# Install zaproxy
RUN pip install --upgrade git+https://github.com/Grunny/zap-cli.git

# Install Lynis
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C80E383C3DE9F082E01391A0366C67DE91CA5D5F                           && \
    echo 'Acquire::Languages "none";' | tee /etc/apt/apt.conf.d/99disable-translations                                          && \
    echo "deb https://packages.cisofy.com/community/lynis/deb/ stretch main" |  tee /etc/apt/sources.list.d/cisofy-lynis.list   
RUN apt update
RUN apt-get install -y unzip                                                                                                                  && \ 
RUN apt install lynis                                                                                                           && \
    rm -rf /var/lib/apt/lists/*


# Install OWASP Dependency Check

ENV version_url=https://jeremylong.github.io/DependencyCheck/current.txt
ENV download_url=https://dl.bintray.com/jeremy-long/owasp

RUN wget -O /tmp/current.txt ${version_url}                                 
RUN version=$(cat /tmp/current.txt)                                         
RUN file="dependency-check-${version}-release.zip"                          
RUN wget "$download_url/$file"                                              
RUN unzip ${file}                                                           
RUN rm ${file}                                                              
RUN mkdir -p /opt/depcheck                                                  
RUN mv dependency-check /opt/depcheck                                       
RUN chown -R ${user}:${user} /opt/depcheck/dependency-check                 
RUN mkdir -p /opt/depcheck/report                                           
RUN chown -R ${user}:${user} /opt/depcheck/report                                        
   # apt-get remove --purge -y wget                                         && \
   # apt-get autoremove -y                                                   
   # rm -rf /var/lib/apt/lists/* /tmp/*
 
USER ${user}
VOLUME ["/src" "/usr/share/dependency-check/data" "/report"]
WORKDIR /src

CMD ["--help"]
ENTRYPOINT ["/usr/share/dependency-check/bin/dependency-check.sh"]

#RUN chmod 755 ${PWD} *



#  Install reporting tools

#  Connect to elk containher
#  docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk <repo-user>/elk
#  Install certificates

#  VOLUME ["/opt/tp"]