# salt - домашнее задание
Create nginx instance with firewall
+++++++++++++++++++++++++++++++++++++++++++++++++
Ход работы:
+ 1. Создание ВМ (виртуальной машины) скриптом терраформ 
```
terraform apply --auto-approve
```
+ 2. Установка на виртуалку Saltstack
```
curl -L https://bootstrap.saltstack.com -o install_salt.sh
```
++ 2.1 Запускаем скрипты поочерёдно: 1. - для мастера, 2. - для миньона
```
sudo sh install_salt.sh -P -M -N
#установка мастера
```
и для миньона
```
sudo sh install_salt.sh -P
```
+ 3. Конфигурируем мастера
```
[root@wvds128577 adminroot]# vi /etc/salt/master
interface: 0.0.0.0
ipv6: False
#обязательно указать в конфиге мастера каталоги для файлов состояний!!!
file_roots:
  base:
    - /srv/salt
```
Перезагружаем сервис **salt-master
```
[root@wvds128577 adminroot]# systemctl restart salt-master
#проверим статус:
● salt-master.service - The Salt Master Server
   Loaded: loaded (/usr/lib/systemd/system/salt-master.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-05-10 12:10:34 UTC; 7s ago
     Docs: man:salt-master(1)
           file:///usr/share/doc/salt/html/contents.html
           https://docs.saltstack.com/en/latest/contents.html
 Main PID: 3590 (salt-master)
   CGroup: /system.slice/salt-master.service
           ├─3590 /usr/bin/python /usr/bin/salt-master
           ├─3593 /usr/bin/python /usr/bin/salt-master
           ├─3600 /usr/bin/python /usr/bin/salt-master
           ├─3603 /usr/bin/python /usr/bin/salt-master
           ├─3604 /usr/bin/python /usr/bin/salt-master
           ├─3605 /usr/bin/python /usr/bin/salt-master
           ├─3606 /usr/bin/python /usr/bin/salt-master
           ├─3607 /usr/bin/python /usr/bin/salt-master
           ├─3608 /usr/bin/python /usr/bin/salt-master
           ├─3609 /usr/bin/python /usr/bin/salt-master
           ├─3610 /usr/bin/python /usr/bin/salt-master
           ├─3617 /usr/bin/python /usr/bin/salt-master
           ├─3618 /usr/bin/python /usr/bin/salt-master
           ├─3969 /bin/sh - /usr/sbin/virt-what
           ├─3973 /bin/sh - /usr/sbin/virt-what
           ├─3989 /bin/sh -c rpm --eval "%{_host_cpu}"
           ├─4016 /usr/bin/python /usr/bin/salt-master
           ├─4045 /usr/bin/python /usr/bin/salt-master
           ├─4060 /bin/sh - /usr/sbin/virt-what
           └─4068 /bin/sh - /usr/sbin/virt-what

May 10 12:10:33 wvds128577 systemd[1]: Stopped The Salt Master Server.
May 10 12:10:33 wvds128577 systemd[1]: Starting The Salt Master Server...
```
+ 4. Конфигурируем миньона
```
/etc/salt/minion
#в конфигурации миньона выставляем параметры связи с мастером
master: 127.0.0.1
ipv6: False
master_port: 4506
#вставляем отпечаток ключа мастера в конфигурацию миньона (описано подробнее ниже)
master_finger: '15:dd:3d:36:26:06:1a:4a:40:9d:e7:fc:bf:cd:3c:0a:17:fe:71:60:f1:2d:ba:66:01:99:da:25:f1:3a:05:42'
```
+ 4.1 Проверяем работу миньона после изменения конфигурации (systemctl restart salt-minion)
```
[root@wvds128577 adminroot]# systemctl status salt-minion
● salt-minion.service - The Salt Minion
   Loaded: loaded (/usr/lib/systemd/system/salt-minion.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-05-10 11:54:09 UTC; 21min ago
     Docs: man:salt-minion(1)
           file:///usr/share/doc/salt/html/contents.html
           https://docs.saltstack.com/en/latest/contents.html
 Main PID: 1317 (salt-minion)
   CGroup: /system.slice/salt-minion.service
           ├─1317 /usr/bin/python /usr/bin/salt-minion
           ├─1361 /usr/bin/python /usr/bin/salt-minion
           └─1363 /usr/bin/python /usr/bin/salt-minion

May 10 11:54:09 wvds128577 systemd[1]: Starting The Salt Minion...
May 10 11:54:09 wvds128577 systemd[1]: Started The Salt Minion.
```
+ 5. Привязка миньона к мастеру производится "принтом" ключей на мастере и внесением хэша ключа master.pub в конфигурацию миньона
```
[root@wvds128577 adminroot]# sudo salt-key --finger-all
Local Keys:
master.pem:  a5:5b:32:59:ec:dc:d7:6b:4a:da:ab:b8:39:88:96:cf:27:75:04:1e:db:ae:2a:ef:36:c7:4f:1f:a7:5f:de:07
master.pub:  15:dd:3d:36:26:06:1a:4a:40:9d:e7:fc:bf:cd:3c:0a:17:fe:71:60:f1:2d:ba:66:01:99:da:25:f1:3a:05:42
Accepted Keys:
wvds128577:  d0:db:e4:4b:8d:9f:2f:7b:18:1c:64:77:61:41:a2:0b:0e:37:f1:13:80:6c:b0:21:b3:64:37:6e:90:30:56:8f
```
+ 5.1 Принимаем конфигурацию миньона на мастере
```
[root@wvds128577 adminroot]# salt-key -A
```
+ 6. Связка миньона и мастера активирована и миньон готов принимать команды от мастера для выполнения. 
+ 6.1 Команды для миньона формируются файлами (формулами) '*.sls'
+ 6.2 Формула для установки nginx
```
[root]# vi /srv/salt/nginx.sls
nginx_pkg:
  pkg.installed:
    - name: nginx

nginx_service:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: nginx_pkg
```
+ 6.3 Формула для установки firewalld и его активации на хосте
```
[root]# vi /srv/salt/firewalld.sls
firewalld:
  pkg.installed:
    - name: firewalld
  service.running:
    - enable: True
    - require:
      - pkg: firewalld
```
+ 6.4 Формула для настройки проброса портов 
```
[root]# vi /srv/salt/public.sls
public:
  firewalld.present:
    - name: public
    - block_icmp:
      - echo-reply
      - echo-request
    - default: False
    - masquerade: True
    - ports:
      - 22/tcp
      - 25/tcp
      - 80/tcp
```
+ 6.5 Исполняющий файл для всех формул выглядит следующим образом
```
[root]# vi /srv/salt/top.sls
base:
   '*':
      - nginx
      - firewalld
      - public
```
+ 6.6 На выходе мы получим выполнение миньоном заданий, находящихся в файле top.sls в указанной очерёдности
```
[root@wvds128577 salt]# salt '*' state.apply
#
wvds128577:
----------
          ID: nginx_pkg
    Function: pkg.installed
        Name: nginx
      Result: True
     Comment: All specified packages are already installed
     Started: 12:29:54.915843
    Duration: 939.373 ms
     Changes:
----------
          ID: nginx_service
    Function: service.running
        Name: nginx
      Result: True
     Comment: The service nginx is already running
     Started: 12:29:55.857661
    Duration: 66.654 ms
     Changes:
----------
          ID: firewalld
    Function: pkg.installed
      Result: True
     Comment: All specified packages are already installed
     Started: 12:29:55.924707
    Duration: 22.482 ms
     Changes:
----------
          ID: firewalld
    Function: service.running
      Result: True
     Comment: The service firewalld is already running
     Started: 12:29:55.947489
    Duration: 50.226 ms
     Changes:
----------
          ID: public
    Function: firewalld.present
      Result: True
     Comment: 'public' is already in the desired state.
     Started: 12:29:56.001807
    Duration: 1893.966 ms
     Changes:

Summary for wvds128577
------------
Succeeded: 5
Failed:    0
------------
Total states run:     5
Total run time:   2.973 s
```
Задание выполнено: На хосте под управлением salt установлен nginx, firewalld и проброшены порты для работы nginx.
