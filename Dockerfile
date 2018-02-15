FROM concourse/git-resource

RUN apk add --update coreutils
RUN mv /opt/resource /opt/git-resource

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*
