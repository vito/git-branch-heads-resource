FROM concourse/git-resource

ENV LC_ALL C
RUN apk add --update coreutils
RUN mv /opt/resource /opt/git-resource

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*
