FROM mysql:5.7

RUN apt-get update

RUN apt-get install -y openssh-server curl supervisor

# Chuck PHP in there since wp cli needs it to run
RUN apt-get install -y php
RUN apt-get install php7.0-mysqli

RUN mkdir /var/run/sshd

RUN useradd wp -G www-data -d /var/www/html -m
RUN echo 'wp:password' | chpasswd
RUN echo 'AllowUsers wp' >> /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN curl -k https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp

RUN chmod +x /usr/local/bin/wp

RUN ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock

RUN echo "127.0.0.1\tdb" >> /etc/hosts

EXPOSE 22

COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["usr/bin/supervisord"]