# docker-postfix-gmail-relay

## postfix-gmail-relay

    A docker image that use postfix, use Ubuntu 16.04 and add config

## Configurable

    SYSTEM_TIMEZONE = UTC or America/New_York
    MYNETWORKS = "10.0.0.0/8 192.168.0.0/16 172.0.0.0/8"

## Example

    docker run --restart=always -d --name postfix1 \
    -p 9025:25 \
    -e SYSTEM_TIMEZONE="America/New_York" \
    -e MYNETWORKS="10.0.0.0/8 192.168.0.0/16, 172.0.0.0/8,127.0.0.1/32,[::1]/128,[::ffff:127.0.0.0]/104,[fe80::]/64" \
    -e EMAIL="YOUR_EMAIL@gmail.com" \
    -e EMAILPASS="your_password" \
    pylin/postfix-gmail-relay

