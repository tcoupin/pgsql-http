FROM postgres:9.6 as builder

WORKDIR /build
COPY * /build/

RUN apt-get update && \
	apt-get install -y postgresql-server-dev-9.6 build-essential libcurl4-openssl-dev && \
	make

FROM postgres:9.6

RUN apt-get update && \
	apt-get install -y libcurl3 && \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/http.so /usr/lib/postgresql/9.6/lib/
COPY --from=builder /build/http.control /usr/share/postgresql/9.6/extension/
COPY --from=builder /build/http*.sql /usr/share/postgresql/9.6/extension/
COPY init-http.sql /docker-entrypoint-initdb.d/

RUN chmod 755 /usr/lib/postgresql/9.6/lib/http.so && \
	chmod 644 /usr/share/postgresql/9.6/extension/http.control /usr/share/postgresql/9.6/extension/http*.sql

