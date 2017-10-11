FROM debian:stretch

# Update base
RUN export DEBIAN_FRONTEND=noninteractive && apt update && apt upgrade

# Syslog
ADD https://github.com/timonier/syslog-stdout/releases/download/v1.1.1/syslog-stdout.tar.gz /tmp/syslog-stdout.tar.gz
RUN tar fxz /tmp/syslog-stdout.tar.gz -C /usr/sbin

# Install dependencies
RUN echo "deb http://deb.debian.org/debian stretch main\n\
deb-src http://deb.debian.org/debian stretch main\n\
deb http://deb.debian.org/debian stretch-updates main\n\
deb-src http://deb.debian.org/debian stretch-updates main\n\
deb http://security.debian.org stretch/updates main\n\
deb-src http://security.debian.org stretch/updates main\n\
" > /etc/apt/sources.list
RUN apt update
RUN apt -y build-dep pure-ftpd

# Get code
ADD https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.46.tar.gz /tmp/pureftpd.tar.gz
RUN mkdir /usr/local/src/pureftpd
RUN tar xfv /tmp/pureftpd.tar.gz --strip 1 -C /usr/local/src/pureftpd
WORKDIR /usr/local/src/pureftpd
RUN ./configure --without-capabilities --without-inetd --without-shadow --with-altlog --with-language=italian --with-peruserlimits --with-puredb --with-rfc2640 --with-quotas --with-throttling --with-tls
RUN make install

# Add conf
RUN mkdir /config
ADD pureftpd.passwd /config/pureftpd.passwd
ADD pureftpd.conf /config/pureftpd.conf
ADD pureftpd.pem /config/pureftpd.pem
ENV PURE_PASSWDFILE=/config/pureftpd.passwd
ENV PURE_DBFILE=/config/pureftpd.pdb
RUN openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048

# Virtual users
RUN pure-pw mkdb

# Ports
EXPOSE 21 40000-40009

# Volume
VOLUME /config

WORKDIR /config
CMD ["/usr/local/sbin/pure-ftpd", "/config/pureftpd.conf"]
