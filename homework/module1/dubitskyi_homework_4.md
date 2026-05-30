# Домашнє завдання №4

Shweex  
Ubuntu, WSL2

---

## Завдання 1. Менеджери пакетів

Оновив список пакетів:

```
$ sudo apt update
Get:1 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:2 http://archive.ubuntu.com/ubuntu noble InRelease
Fetched 126 kB in 1s (98.2 kB/s)
Reading package lists... Done
```

Встановив tree:

```
$ sudo apt install tree
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  tree
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Setting up tree (2.1.1-2ubuntu3) ...
```

Перевірив що пакет стоїть і яка версія:

```
$ dpkg -l tree
ii  tree  2.1.1-2ubuntu3  amd64  displays an indented directory tree, in color

$ tree --version
tree v2.1.1 © 1996 - 2023 by Steve Baker, Thomas Moore, Francesc Rocher, Florian Sesser, Kyosuke Tokoro
```

Видалив пакет:

```
$ sudo apt remove tree
Reading package lists... Done
Removing tree (2.1.1-2ubuntu3) ...

$ dpkg -l tree
dpkg-query: no packages found matching tree
```

---

## Завдання 2. Керування сервісами через systemctl

Працював з сервісом cron.

Перевірив статус:

```
$ systemctl status cron
● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 19:51:04 CEST
   Main PID: 165 (cron)
```

Зупинив і перевірив що не активний:

```
$ sudo systemctl stop cron

$ systemctl is-active cron
inactive

$ systemctl status cron
○ cron.service - Regular background program processing daemon
     Active: inactive (dead) since Sat 2026-05-30 20:12:08 CEST
```

Запустив знову:

```
$ sudo systemctl start cron

$ systemctl is-active cron
active
```

Додав в автозавантаження:

```
$ sudo systemctl enable cron

$ systemctl is-enabled cron
enabled
```

---

## Завдання 3. Робота з логами

Перейшов в /var/log і подивився останні 10 рядків syslog:

```
$ cd /var/log
$ sudo tail -n 10 syslog
2026-05-30T19:52:08.230834+02:00 DESKTOP-TILGB75 systemd[1]: Finished e2scrub_all.service - Online ext4 Metadata Check for All Filesystems.
2026-05-30T19:52:16.684549+02:00 DESKTOP-TILGB75 chronyd[284]: Selected source 185.125.190.123 (2.ntp.ubuntu.com)
2026-05-30T20:12:08.441203+02:00 DESKTOP-TILGB75 systemd[1]: Stopping cron.service - Regular background program processing daemon...
2026-05-30T20:12:08.452891+02:00 DESKTOP-TILGB75 systemd[1]: cron.service: Deactivated successfully.
2026-05-30T20:12:08.453112+02:00 DESKTOP-TILGB75 systemd[1]: Stopped cron.service - Regular background program processing daemon.
2026-05-30T20:12:15.881044+02:00 DESKTOP-TILGB75 systemd[1]: Started cron.service - Regular background program processing daemon.
```

Помилки через journalctl:

```
$ sudo journalctl -p err -n 5 --no-pager
May 30 19:51:04 DESKTOP-TILGB75 kernel: misc dxg: dxgk: dxgkio_query_adapter_info: Ioctl failed: -22
May 30 19:51:49 DESKTOP-TILGB75 unknown: WSL (271) ERROR: CheckConnection: getaddrinfo() failed: -5
```

Знайшов записи про cron (зупинку і запуск з завдання 2):

```
$ sudo journalctl -u cron | grep -E "Started|Stopped"
May 30 20:12:08 DESKTOP-TILGB75 systemd[1]: Stopped cron.service - Regular background program processing daemon.
May 30 20:12:15 DESKTOP-TILGB75 systemd[1]: Started cron.service - Regular background program processing daemon.
```

---

## Завдання 4. Створення власного сервісу

Створив скрипт ~/myscript.sh:

```bash
#!/bin/bash
LOG_FILE="$HOME/myscript.log"

while true; do
    date >> "$LOG_FILE"
    sleep 1
done
```

```
$ chmod +x ~/myscript.sh
```

Створив /etc/systemd/system/myscript.service:

```ini
[Unit]
Description=My script that writes date every second
After=network.target

[Service]
Type=simple
ExecStart=/home/shweex/myscript.sh
Restart=always
User=shweex

[Install]
WantedBy=multi-user.target
```

Запустив сервіс:

```
$ sudo systemctl daemon-reload
$ sudo systemctl start myscript
$ sudo systemctl status myscript
● myscript.service - My script that writes date every second
     Loaded: loaded (/etc/systemd/system/myscript.service; disabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 20:15:02 CEST
   Main PID: 512 (myscript.sh)
```

Перевірив що пишеться в файл:

```
$ tail -n 5 ~/myscript.log
Sat May 30 20:15:08 CEST 2026
Sat May 30 20:15:09 CEST 2026
Sat May 30 20:15:10 CEST 2026
Sat May 30 20:15:11 CEST 2026
Sat May 30 20:15:12 CEST 2026
```

Додав в автозавантаження:

```
$ sudo systemctl enable myscript
Created symlink /etc/systemd/system/multi-user.target.wants/myscript.service → /etc/systemd/system/myscript.service.
```
