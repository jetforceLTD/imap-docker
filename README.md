# internal imap server

## Description

## Content
     * postfix, dovecot : sieve, quota
     * postfixadmin
     * mysql
     Konfig und doveadm-tools siehe : https://www.debacher.de/wiki/Mail-Quotas_mit_Dovecot

## Installation

see groupware-docker

## Configuration

```
. .env ; vi ${GLOBAL_DIR_SERV}/imap/service/server.key        # cert key file
. .env ; vi ${GLOBAL_DIR_SERV}/imap/service/server.pem        # cert pem file
. .env ; vi ${GLOBAL_DIR_SERV}/imap/service/client-access     # client access defeinitions
. .env ; vi ${GLOBAL_DIR_SERV}/imap/service/quota-warning.sh  # mail for quota warnings
. .env ; ls ${GLOBAL_DIR_SERV}/imap/service/doveconf.d        # individual dovecot config 
```

## imapsync
```
docker exec -i imap imapsync-install
```

