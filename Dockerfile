FROM debian:stretch

# Update
RUN export DEBIAN_FRONTEND=noninteractive && apt update && apt upgrade

# Install dependencies
RUN echo -e "deb http://deb.debian.org/debian stretch main\n\
deb-src http://deb.debian.org/debian stretch main\n\
deb http://deb.debian.org/debian stretch-updates main\n\
deb-src http://deb.debian.org/debian stretch-updates main\n\
deb http://security.debian.org stretch/updates main\n\
deb-src http://security.debian.org stretch/updates main\n\
" > /etc/apt/sources.list
RUN apt update
RUN apt -y build-dep pure-ftpd

# Get code
ADD https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.46.tar.gz /tmp/pure-ftpd.tar.gz
RUN mkdir /usr/local/src/pure-ftpd
RUN tar xfv /tmp/pure-ftpd.tar.gz --strip 1 -C /usr/local/src/pure-ftpd
WORKDIR /usr/local/src/pure-ftpd
RUN ./configure --without-capabilities --without-inetd --without-shadow --with-language=italian --with-quotas --with-throttling --with-tls
RUN make
RUN make install

# Virtual users
RUN pure-pw mkdb

# Ports
EXPOSE 21 40000-40009

/usr/local/sbin/pure-ftpd -c 5 -C 5 -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P wsa.pretecno.com -p 40000:40009 -tls 1
