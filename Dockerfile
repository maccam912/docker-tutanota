FROM ubuntu
MAINTAINER Matt Koski <maccam912@gmail.com>
RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install vim git build-essential wget screen tmux curl python -y

RUN mkdir /Development
RUN cd /Development && git clone git://github.com/joyent/node

RUN cd /Development/node && ./configure && make && make install
RUN rm -rf /Development/node

RUN cd /Development && git clone https://github.com/tutao/tutanota.git

RUN npm install gulp -g
RUN cd /Development/tutanota/web && npm install && gulp dist && cd build

EXPOSE 80:80
EXPOSE 443:443
EXPOSE 3000:3000
