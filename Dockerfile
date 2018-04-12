FROM openjdk:8-jre-alpine

# ensure elasticsearch user exists
RUN addgroup -S elasticsearch && adduser -S -G elasticsearch elasticsearch

# grab su-exec for easy step-down from root
# and bash for "bin/elasticsearch" among others
RUN apk add --no-cache 'su-exec>=0.2' bash

# https://artifacts.elastic.co/GPG-KEY-elasticsearch
ENV GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4

WORKDIR /usr/share/elasticsearch
ENV PATH /usr/share/elasticsearch/bin:$PATH

ENV ELASTICSEARCH_TARBALL="https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-2.4.6.tar.gz" 

RUN set -ex; \
	\
	apk add --no-cache --virtual .fetch-deps \
		wget \
		tar \
	; \
	\
	wget -O elasticsearch.tar.gz "$ELASTICSEARCH_TARBALL"; \
	\
	tar -xf elasticsearch.tar.gz --strip-components=1; \
	rm elasticsearch.tar.gz; \
	\
	apk del .fetch-deps; \
	\
	for path in \
		./data \
		./logs \
		./config \
		./config/scripts \
	; do \
		mkdir -p "$path"; \
		chown -R elasticsearch:elasticsearch "$path"; \
	done;
	\

COPY config ./config

COPY docker-entrypoint.sh /

EXPOSE 9200 9300

RUN chmod -R og+w /usr/share/elasticsearch
USER 1000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["elasticsearch"]

