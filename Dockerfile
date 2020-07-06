FROM alpine:3.12

#                                                               ↓ for `dig` command
RUN apk add --no-cache bash clamav rsyslog wget clamav-libunrar bind-tools rsync sudo

COPY config/* /etc/clamav/
COPY entrypoint.sh /entrypoint.sh
COPY check.sh /check.sh
COPY os.docker-alpine.conf /etc/clamav-unofficial-sigs/os.conf

RUN mkdir /run/clamav/ \
 && chown clamav:clamav /run/clamav \
 && mkdir -p /usr/local/sbin/ \
 && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/clamav-unofficial-sigs.sh -O /usr/local/sbin/clamav-unofficial-sigs.sh \
 && chmod 755 /usr/local/sbin/clamav-unofficial-sigs.sh \
 && mkdir -p /etc/clamav-unofficial-sigs/ \
 && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/master.conf -O /etc/clamav-unofficial-sigs/master.conf \
 && wget https://raw.githubusercontent.com/extremeshok/clamav-unofficial-sigs/master/config/user.conf -O /etc/clamav-unofficial-sigs/user.conf

VOLUME ["/data"]
EXPOSE 3310/tcp

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --start-period=500s CMD /check.sh
