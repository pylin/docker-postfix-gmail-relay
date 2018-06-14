# This is a comment

FROM ubuntu:16.04
MAINTAINER pylin "poyu.lin@gmail.com"

USER root

RUN apt update && \
#>> Postfix setup
apt -q -y install \
    postfix \
    mailutils \
    libsasl2-2 \
    ca-certificates \
    tzdata \
    apt-utils \
    libsasl2-modules && \
# main.cf
postconf -e smtpd_banner="\$myhostname ESMTP" && \
postconf -e mydestination="$myhostname localhost.$mydomain" && \
postconf -e inet_protocols=all && \
postconf -e inet_interfaces=all && \
postconf -e smtp_helo_timeout=180s && \
postconf -e smtp_mail_timeout=180s && \
postconf -e smtp_quit_timeout=180s && \
postconf -e smtp_rcpt_timeout=180s && \
postconf -e smtpd_delay_reject=yes && \
postconf -e smtpd_helo_required=yes && \
postconf -e smtpd_tls_security_level=may && \
postconf -e smtp_tls_security_level=may && \
postconf -e smtpd_sasl_authenticated_header=yes && \
postconf -e compatibility_level=2 && \
postconf -e strict_rfc821_envelopes=no && \
postconf -e smtpd_delay_reject=yes && \
postconf -e smtpd_helo_required=yes && \
postconf -e smtpd_tls_mandatory_protocols=!SSLv2,!SSLv3 && \
postconf -e smtpd_policy_service_timeout=48 && \
postconf -e initial_destination_concurrency=14 && \
postconf -e relayhost=[smtp.gmail.com]:587 && \
postconf -e smtp_sasl_auth_enable=yes && \
postconf -e smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd && \
postconf -e smtp_sasl_security_options=noanonymous && \
postconf -e smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt  && \
postconf -e smtp_use_tls=yes && \
 
#>> Setup syslog-ng to echo postfix log data to the screen
apt install -q -y \
    syslog-ng \
    syslog-ng-core && \
# system() can't be used since Docker doesn't allow access to /proc/kmsg.
# https://groups.google.com/forum/#!topic/docker-user/446yoB0Vx6w
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf && \
# https://github.com/LyleScott/docker-postfix-gmail-relay/issues/1
sed -i '/^smtp_tls_CAfile =/d' /etc/postfix/main.cf && \

apt-get install -q -y \
    supervisor

COPY supervisord.conf /etc/supervisor/
COPY init.sh /opt/init.sh

#>> Cleanup
RUN rm -rf /var/lib/apt/lists/* /tmp/* && \
apt autoremove -y && \
apt clean

EXPOSE 25

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

