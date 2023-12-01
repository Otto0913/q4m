FROM ubuntu:jammy

ENV PATH /usr/local/mysql/bin:$PATH

# install required packages
# https://github.com/openssl/openssl#build-and-install
# https://dev.mysql.com/doc/refman/8.0/en/source-installation-prerequisites.html
RUN apt-get update \
    && apt-get install -y perl \
    && apt-get install -y wget cmake gcc g++ libncurses-dev libudev-dev dpkg-dev pkg-config bison libssl-dev rapidjson-dev\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV Q4M_PLUGIN q4m
ARG MYSQL_VERSION

# install mysql-build + q4m plugin installer, build mysql + q4m, remove workdir
COPY ./ /tmp/q4m
RUN cd /tmp \
    && wget https://github.com/Otto0913/mysql-build/archive/master.tar.gz \
    && tar xvzf master.tar.gz \
    && mv mysql-build-master /usr/local/mysql-build \
    && mv /tmp/q4m/docker/${Q4M_PLUGIN} /usr/local/mysql-build/share/mysql-build/plugins/${Q4M_PLUGIN} \
    && cd ~/ \
    && /usr/local/mysql-build/bin/mysql-build -v ${MYSQL_VERSION} /usr/local/mysql ${Q4M_PLUGIN} \
    && rm -rf /usr/local/mysql-build \
    && rm /tmp/master.tar.gz

# user, group
RUN mkdir /var/lib/mysql \
    && groupadd mysql \
    && useradd -r -g mysql -s /bin/false mysql \
    && chown -R mysql:mysql /var/lib/mysql

# setup mysql
COPY docker/my.cnf /etc/mysql/my.cnf
RUN mysqld --initialize-insecure --user=mysql \
    && mysql_ssl_rsa_setup \
    && mysqld --daemonize --skip-networking --user mysql --socket /tmp/mysql.sock \
    && echo "CREATE USER 'root'@'%'; GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES; " | mysql -uroot -hlocalhost --socket /tmp/mysql.sock \
    && cat /usr/local/mysql/support-files/install-q4m.sql | mysql -uroot -hlocalhost --socket /tmp/mysql.sock \
    && mysqladmin shutdown -uroot --socket /tmp/mysql.sock

EXPOSE 3306
ENTRYPOINT [ "mysqld", "--user=mysql" ]
