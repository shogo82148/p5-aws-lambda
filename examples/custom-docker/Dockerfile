FROM perl:5.32-slim-buster
RUN mkdir -p /var/task \
    && apt-get update \
    && apt-get install -y --no-install-recommends gcc libc6-dev \
    && cpanm --notest AWS::Lambda \
    && apt-get purge -y --auto-remove gcc libc6-dev \
    && rm -fr /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -fr ./cpanm /root/.cpanm /tmp/*
COPY handler.pl /var/task/
WORKDIR /var/task
ENTRYPOINT [ "/usr/local/bin/perl", "-MAWS::Lambda::Bootstrap", "-e", "bootstrap(@ARGV)" ]
CMD [ "handler.handle" ]
