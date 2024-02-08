FROM glendmaatita/phpbase

# Install the composer packages using www-data user
WORKDIR /app
RUN chown www-data:www-data /app
COPY --chown=www-data:www-data . .
USER www-data
RUN composer install

COPY ./user/config-sample.php ./user/config.php

# Setup nginx & supervisor as root user
USER root
RUN apk add --no-progress --quiet --no-cache nginx supervisor
COPY ./docker/nginx.conf /etc/nginx/http.d/default.conf
COPY ./docker/supervisord.conf /etc/supervisord.conf

# Apply the required changes to run nginx as www-data user
RUN chown -R www-data:www-data /run/nginx /var/lib/nginx /var/log/nginx && \
    sed -i '/user nginx;/d' /etc/nginx/nginx.conf
# Switch to www-user
USER www-data

EXPOSE 8000
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
