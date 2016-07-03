FROM concourse/buildroot:git

ADD assets/ /opt/resource/
RUN chmod +x /opt/resource/*
