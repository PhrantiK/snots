/bin/sh

apt update; \
apt install msmtp -y; \
apt install msmtp-mta -y; \

echo ""; \
echo ""; \
echo "Starting E-Mail Notification Configuration...."; \
echo ""; \

printf "defaults\n" >> /etc/msmtprc; \
printf "   port 587\n" >> /etc/msmtprc; \
printf "   tls on\n" >> /etc/msmtprc; \
printf "   tls_starttls on\n" >> /etc/msmtprc; \
printf "   auth on\n" >> /etc/msmtprc; \
printf "   aliases /etc/aliases\n" >> /etc/msmtprc; \
printf "\n" >> /etc/msmtprc; \

printf "logfile /var/log/msmtp\n" >> /etc/msmtprc; \
printf "\n" >> /etc/msmtprc; \

printf "account outbound-mail\n" >> /etc/msmtprc; \

echo -n "Enter a mail server's FQDN: "; \
read VAR1; \
printf "   host $VAR1\n" >> /etc/msmtprc; \
printf "\n" >> /etc/msmtprc; \
unset VAR1; \

echo -n "Enter FROM address: "; \
read VAR2; \
printf "   from $VAR2\n" >> /etc/msmtprc; \
printf "\n" >> /etc/msmtprc; \
printf "default: $VAR2\n" >> /etc/aliases; \
newaliases; \
unset VAR2; \

echo -n "Enter Username: "; \
read VAR3; \
printf "   user $VAR3\n" >> /etc/msmtprc; \
unset VAR3; \

echo -n "Enter Password: "; \
read VAR4; \
printf "   password $VAR4\n" >> /etc/msmtprc; \
printf "\n" >> /etc/msmtprc; \
unset VAR4; \

printf "account default : outbound-mail" >> /etc/msmtprc; \
echo ""; \
echo "Settings Applied."; \
echo ""; \
echo ""; \

groups msmtp; \
touch /var/log/msmtp; \
chown msmtp:msmtp /var/log/msmtp; \
chmod 660 /var/log/msmtp; \

echo ""; \
echo ""; \
echo -n "Enter an email address: "; \
read VAR5; \
echo -e "Subject: MySubject\r\n\r\ntestmail" | msmtp $VAR5; \
unset VAR5;
