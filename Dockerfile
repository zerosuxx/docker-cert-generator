FROM alpine

RUN apk add --no-cache openssl bash

COPY ./generate-cert.sh /usr/local/bin/generate-cert

RUN chmod +x /usr/local/bin/generate-cert

RUN adduser -D app

USER app

RUN mkdir ~/certs

WORKDIR /home/app/certs

CMD ["/usr/local/bin/generate-cert"]
