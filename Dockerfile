FROM ubuntu
MAINTAINER Matt Koski <maccam912@gmail.com>
RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install vim git build-essential wget screen tmux curl python nginx-full openssl -y

RUN mkdir /Development
RUN cd /Development && git clone git://github.com/joyent/node

RUN cd /Development/node && ./configure && make && make install
RUN rm -rf /Development/node

RUN cd /Development && git clone https://github.com/tutao/tutanota.git

RUN npm install gulp -g
RUN cd /Development/tutanota/web && npm install && gulp dist && cd build

RUN cat "server {
    listen       80 default;
    location / {
        root   /var/www/tutanota/;
        index  index.html;
    }
}

server {
    listen       443 default;
    location / {
        root   /var/www/tutanota/;
        index  index.html;
    }
    
    ssl on;
    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/server.key;
}" > /etc/nginx/sites-available/tutanota.conf

RUN cat "#!/bin/bash
set -ue


mkdir -p /var/www
cp -r /usr/local/src/tutanota/web/build /var/www/tutanota

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/tutanota.conf /etc/nginx/sites-enabled/tutanota.conf

/etc/init.d/nginx restart" > hook1.sh && sh hook1.sh

RUN cat "#!/bin/bash
set -ue

mkdir -p /etc/nginx/ssl

# create a self-signed certificate in one line
openssl req -subj '/CN=domain.com/O=My Company Name LTD./C=US' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/nginx/server.key -out /etc/nginx/ssl/server.crt" > hook2.sh && sh hook2.sh

RUN /etc/init.d/nginx stop
RUN /etc/init.d/nginx start

EXPOSE 80:80
EXPOSE 443:443
EXPOSE 3000:3000
