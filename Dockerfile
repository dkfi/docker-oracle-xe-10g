FROM debian:wheezy

MAINTAINER Kristian Du <kristian.du@gmail.com>

ADD oracle-xe_10.2.0.1-1.1_i386.debaa /
ADD oracle-xe_10.2.0.1-1.1_i386.debab /
ADD oracle-xe_10.2.0.1-1.1_i386.debac /
RUN cat /oracle-xe_10.2.0.1-1.1_i386.deba* > /oracle-xe_10.2.0.1-1.1_i386.deb

# Install sshd
RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install -y \
   bc:i386 \
   libaio1:i386 \
   libc6-i386 \
   net-tools \
   openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:admin' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

# Install Oracle
RUN dpkg -i /oracle-xe_10.2.0.1-1.1_i386.deb

RUN printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

RUN echo 'export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server' >> /etc/bash.bashrc
RUN echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib' >> /etc/bash.bashrc
RUN echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc
RUN echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

# Remove installation files
RUN rm /oracle-xe_10.2.0.1-1.1_i386.deb*
RUN apt-get clean

EXPOSE 1521 22

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/listener.ora; \
	service oracle-xe start; \
	/usr/sbin/sshd -D
