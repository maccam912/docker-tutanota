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

RUN echo "server {\n listen       80 default;\n    location / {\n        root   /var/www/tutanota/;\n        index  index.html;\n    }\n}\n\nserver {\n    listen       443 default;\n    location / {\n        root   /var/www/tutanota/;\n        index  index.html;\n    }\n\n    ssl on;\n    ssl_certificate /etc/nginx/ssl/server.crt;\n    ssl_certificate_key /etc/nginx/server.key;\n}" > /etc/nginx/sites-available/tutanota.conf

RUN echo "#!/bin/bash\nset -ue\n\nmkdir -p /var/www\ncp -r /usr/local/src/tutanota/web/build /var/www/tutanota\n\nrm /etc/nginx/sites-enabled/default\nln -s /etc/nginx/sites-available/tutanota.conf /etc/nginx/sites-enabled/tutanota.conf\n\n/etc/init.d/nginx restart" > hook1.sh && sh hook1.sh

RUN echo "#!/bin/bash\nset -ue\n\nmkdir -p /etc/nginx/ssl\n\n# create a self-signed certificate in one line\nopenssl req -subj '/CN=domain.com/O=My Company Name LTD./C=US' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout /etc/nginx/server.key -out /etc/nginx/ssl/server.crt" > hook2.sh && sh hook2.sh

RUN /etc/init.d/nginx stop
RUN /etc/init.d/nginx start

EXPOSE 80:80
EXPOSE 443:443
EXPOSE 3000:3000
