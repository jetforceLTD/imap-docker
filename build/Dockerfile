FROM alpine:3.10
MAINTAINER Uni Mock unimock@gate-m.de

RUN addgroup -S -g 5000 vmail
RUN adduser -S -u 5000 -g vmail vmail

RUN apk add --update bash postfix postfix-mysql openssl rsyslog mysql-client supervisor dcron rsync tzdata dovecot dovecot-mysql dovecot-pigeonhole-plugin rspamd-client

#RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
#    && apk add --no-cache \
#    dovecot dovecot-mysql dovecot-pigeonhole-plugin dovecot-pigeonhole-plugin-extdata 

RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
RUN cp -f /usr/share/zoneinfo/Europe/Berlin /etc/localtime

############################################################################################
#
# cron
#
RUN mkdir -p /var/log/cron && mkdir -m 0644 -p /var/spool/cron/crontabs && touch /var/log/cron/cron.log && mkdir -m 0644 -p /etc/cron.d && \
    echo '#* * * * * /home/joe/myscript >> /home/log/myscript.log 2>&1'                 >  /etc/cron.d/template && \
    echo '# An empty line is required at the end of this file for a valid cron file.'   >> /etc/cron.d/template && \
    rm -f /etc/crontabs/root
############################################################################################

ADD postfix /etc/postfix
ADD dovecot /etc/dovecot

RUN chgrp postfix /etc/postfix/sql/*.cf && \
    chgrp vmail /etc/dovecot/dovecot.conf && \
    chmod g+r /etc/dovecot/dovecot.conf

RUN postconf -e virtual_uid_maps=static:5000 && \
    postconf -e virtual_gid_maps=static:5000 && \
    postconf -e dovecot_destination_recipient_limit=1 && \
    postconf -F '*/*/chroot = n'
    # specially for docker

RUN echo "dovecot   unix  -       n       n       -       -       pipe"  >> /etc/postfix/master.cf && \
    echo '    flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/dovecot/deliver -d ${recipient}' >> /etc/postfix/master.cf

RUN sed -i 's/#submission/submission/g' /etc/postfix/master.cf

#SMTP ports
EXPOSE 25
EXPOSE 587  
# IMAP ports  
EXPOSE 143
EXPOSE 993
############################################################################################
#
# docker-extensions
#
RUN mkdir -p /usr/local/bin
COPY ./bin/*             /usr/local/bin/
RUN chmod a+x /usr/local/bin/*
#RUN chmod a+x /usr/local/sbin/* 2>/dev/null
############################################################################################
#
# supervisor
#
RUN echo ". /etc/profile" > /root/.bashrc
RUN echo "export PS1='\H:\w\\$ '" >> /etc/profile
RUN echo "alias ll='ls -alF'"     >> /etc/profile
RUN echo 'export TERM="xterm"'    >> /etc/profile
#
# establisch supervisord
#
ADD /supervisor /etc/supervisor
RUN ln -sf /etc/supervisor/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisor && chmod a+rw var/log/supervisor
# link /etc/init.d/ startup scripts to supervisor
RUN ( cd /etc/supervisor/services.d ; ls * | while read i; do mv /etc/init.d/$i /etc/init.d/$i-orig ;  ln -sf /etc/supervisor/super-init.sh /etc/init.d/$i ; done 2>/dev/null )
RUN ln -sf    /etc/supervisor/systemctl /bin/systemctl
RUN chmod a+x /etc/supervisor/* /etc/supervisor/*.d/*
COPY /supervisor/invoke-rc.d /usr/sbin/invoke-rc.d
COPY /supervisor/reload      /sbin/reload
RUN  chmod a+x /sbin/reload /usr/sbin/invoke-rc.d
EXPOSE 9001
############################################################################################
#
# create directory for service volume
#
RUN mkdir -p /service ; chmod a+rwx /service
############################################################################################
#
# startup script
#
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh
CMD ["/start.sh"]

