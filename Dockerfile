FROM debian:stretch

# Update
RUN export DEBIAN_FRONTEND=noninteractive && apt update && apt upgrade

# Install
RUN apt -y install pure-ftpd



# Virtual users
RUN pure-pw mkdb


/usr/sbin/pure-ftpd -c 5 -C 5 -l puredb:/etc/pure-ftpd/pureftpd.pdb -E -j -R -P wsa.pretecno.com -p 40000:40009 -tls 1
