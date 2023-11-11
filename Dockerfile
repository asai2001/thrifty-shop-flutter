FROM httpd:2.4

# Create app directory
WORKDIR /usr/local/apache2/htdocs/

COPY ./build/web/ /usr/local/apache2/htdocs/

# Set ServerName directive to suppress the error message
RUN echo "ServerName localhost" >> /usr/local/apache2/conf/httpd.conf