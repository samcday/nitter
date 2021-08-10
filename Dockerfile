FROM nimlang/nim:alpine as nim
EXPOSE 8080

RUN apk --no-cache add libsass-dev libffi-dev openssl-dev redis openssh-client

COPY . /src/nitter
WORKDIR /src/nitter

RUN nimble build -y -d:release --passC:"-flto" --passL:"-flto" \
    && strip -s nitter \
    && nimble scss

FROM alpine:3.14.1
MAINTAINER me@samcday.com
WORKDIR /src/
RUN apk --no-cache add pcre-dev sqlite-dev
COPY --from=nim /src/nitter/nitter /src/nitter/nitter.conf ./
COPY --from=nim /src/nitter/public ./public
CMD ["/src/nitter/nitter"]
