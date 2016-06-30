docker-oracle-xe-10g
====================

(based on the work done by Wei-Ming Wu <wnameless@gmail.com> on
[wnameless/docker-oracle-xe-11g](https://github.com/wnameless/docker-oracle-xe-11g)

Oracle Express Edition 10g Release 2 (10.2.0.1) 32-bit on Debian 7.0 Wheezy.


### Installation
```
docker pull dkfi/docker-oracle-xe-10g
```

Run with 22 and 1521 ports opened:
```
docker run -d -p 49160:22 -p 49161:1521 dkfi/docker-oracle-xe-10g
```

Connect database with following setting:
```
hostname: localhost
port: 49161
sid: xe
username: system
password: oracle
```

Password for SYS & SYSTEM
```
oracle
```

Login by SSH
```
ssh root@localhost -p 49160
password: admin
```
