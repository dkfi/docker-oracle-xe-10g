FROM debian:wheezy

MAINTAINER Kristian Du <kristian.du@gmail.com>

ENV ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server
ENV LD_LIBRARY_PATH=$ORACLE_HOME/lib
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV ORACLE_SID=XE

ADD oracle-xe_10.2.0.1-1.1_i386.debaa /
ADD oracle-xe_10.2.0.1-1.1_i386.debab /
ADD oracle-xe_10.2.0.1-1.1_i386.debac /

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
       bc:i386 \
       libaio1:i386 \
       libc6-i386 \
       net-tools \
       openssh-server && \
    apt-get clean && \
    mkdir /var/run/sshd && \
    echo 'root:admin' | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    echo "export VISIBLE=now" >> /etc/profile && \
    cat /oracle-xe_10.2.0.1-1.1_i386.deba* > /oracle-xe_10.2.0.1-1.1_i386.deb && \
    dpkg -i /oracle-xe_10.2.0.1-1.1_i386.deb && \
    rm /oracle-xe_10.2.0.1-1.1_i386.deb* && \
    printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure && \
    echo 'export ORACLE_HOME=/usr/lib/oracle/xe/app/oracle/product/10.2.0/server' >> /etc/bash.bashrc && \
    echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib' >> /etc/bash.bashrc && \
    echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bash.bashrc && \
    echo 'export ORACLE_SID=XE' >> /etc/bash.bashrc

EXPOSE 1521 22 8080

CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/listener.ora; \
    sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /usr/lib/oracle/xe/app/oracle/product/10.2.0/server/network/admin/tnsnames.ora; \
    service oracle-xe start; \
    su -c "$ORACLE_HOME/bin/lsnrctl start" oracle; \
    echo "alter system disable restricted session;" | sqlplus -s SYSTEM/oracle; \
    echo "EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);" | sqlplus -s SYSTEM/oracle; \
    /usr/sbin/sshd -D
