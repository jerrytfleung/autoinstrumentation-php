# Build args declared before the first FROM are usable in FROM instructions.
ARG PHP_IMAGE=php:8.1
ARG version=1.2.1

# Parameterized extension builder — driven by docker-bake.hcl.
FROM ${PHP_IMAGE} AS builder
ARG version
ARG LIBC=glibc
ARG THREAD=non-zts

WORKDIR /build/${LIBC}/${THREAD}

RUN curl -fsSL https://github.com/php/pie/releases/latest/download/pie.phar -o /usr/local/bin/pie \
    && chmod +x /usr/local/bin/pie \
    && pie install open-telemetry/ext-opentelemetry:${version} --auto-install-build-tools \
    && cp /usr/local/lib/php/extensions/no-debug-${THREAD}-*/opentelemetry.so .

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY composer.json .
RUN composer install --ignore-platform-reqs
