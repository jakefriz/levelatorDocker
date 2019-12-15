FROM i386/ubuntu:16.04

RUN apt-get update &&\
    apt-get -y install wget bzip2 apt-utils python-software-properties software-properties-common

COPY installLevelator.sh .

RUN chmod +x installLevelator.sh &&\
    ./installLevelator.sh

CMD ['levelator']