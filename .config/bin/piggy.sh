/bin/sh

## Set pigz to replace gzip, 2x faster gzip compression
    sed -i "s/#pigz:.*/pigz: 1/" /etc/vzdump.conf
    cat  <<EOF > /bin/pigzwrapper
#!/bin/sh
PATH=/bin:\$PATH
GZIP="-1"
exec /usr/bin/pigz "\$@"
EOF
    mv -f /bin/gzip /bin/gzip.original
    cp -f /bin/pigzwrapper /bin/gzip
    chmod +x /bin/pigzwrapper
    chmod +x /bin/gzip
