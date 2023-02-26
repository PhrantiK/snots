#!/bin/sh

set -e

MSMTPRC="/etc/msmtprc"
ALIASES="/etc/aliases"
LOGFILE="/var/log/msmtp"

apt update
apt install msmtp msmtp-mta -y

cat <<EOF

Starting E-Mail Notification Configuration....

EOF

cat <<EOF >> "$MSMTPRC"
defaults
   port 587
   tls on
   tls_starttls on
   auth on
   aliases $ALIASES

logfile $LOGFILE

account outbound-mail
EOF

read -r -p "Enter a mail server's FQDN: " SERVER_NAME
cat <<EOF >> "$MSMTPRC"
   host $SERVER_NAME

EOF

read -r -p "Enter FROM address: " FROM_ADDRESS
cat <<EOF >> "$MSMTPRC"
   from $FROM_ADDRESS

EOF

read -r -p "Enter Username: " USERNAME
cat <<EOF >> "$MSMTPRC"
   user $USERNAME

EOF

read -r -p "Enter Password: " PASSWORD
cat <<EOF >> "$MSMTPRC"
   password $PASSWORD

account default : outbound-mail
EOF

cat <<EOF

Settings Applied.

EOF

read -r -p "Enter email address for root: " ROOT_EMAIL
echo "default: $ROOT_EMAIL" >> "$ALIASES"
newaliases

groups msmtp
touch "$LOGFILE"
chown msmtp:msmtp "$LOGFILE"
chmod 660 "$LOGFILE"

cat <<EOF

Send a Test Email

EOF

read -r -p "Enter an email address: " TEST_EMAIL
echo -e "Subject: MySubject\r\n\r\ntestmail" | msmtp "$TEST_EMAIL"

unset SERVER_NAME FROM_ADDRESS USERNAME PASSWORD ROOT_EMAIL TEST_EMAIL
