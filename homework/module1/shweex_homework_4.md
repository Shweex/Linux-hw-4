# Домашнє завдання №4. Пакети, сервіси та журнали

**Виконав:** Shweex  
**Система:** Ubuntu (WSL2)

> **Примітка:** Якщо ваше прізвище інше — перейменуйте файл на `ваше_прізвище_homework_4.md`.

> **Швидке виконання:** усі команди можна запустити одразу скриптом:
> ```bash
> cd /mnt/c/Users/shweex/Documents/cursor_projects/Linux-hw-4/homework/module1
> bash run_homework_4.sh
> ```

---

## Завдання 1. Менеджери пакетів (2 бали)

### 1.1 Оновлення списку пакетів

```bash
sudo apt update
```

### 1.2 Встановлення утиліти tree

```bash
sudo apt install -y tree
```

> Якщо `tree` недоступний, замініть на `htop`: `sudo apt install -y htop`

### 1.3 Перевірка встановлення та версія пакета

```bash
dpkg -l tree
tree --version
```

### 1.4 Видалення встановленого пакета

```bash
sudo apt remove -y tree
dpkg -l tree
```

---

## Завдання 2. Керування сервісами через systemctl (2 бали)

> Використовуємо сервіс **cron** (альтернатива: `ssh` або `nginx`, якщо вони встановлені).

### 2.1 Перевірка статусу сервісу

```bash
systemctl status cron
```

### 2.2 Зупинка сервісу та перевірка

```bash
sudo systemctl stop cron
systemctl is-active cron
systemctl status cron
```

### 2.3 Запуск сервісу знову

```bash
sudo systemctl start cron
systemctl is-active cron
systemctl status cron
```

### 2.4 Додавання сервісу в автозавантаження

```bash
sudo systemctl enable cron
systemctl is-enabled cron
```

---

## Завдання 3. Робота з логами (2 бали)

### 3.1 Останні 10 рядків syslog (або messages)

```bash
cd /var/log
sudo tail -n 10 syslog
```

> Якщо файлу `syslog` немає: `sudo tail -n 10 messages`

### 3.2 Перегляд помилок через journalctl (рівень err)

```bash
sudo journalctl -p err --no-pager
```

Перегляд лише останніх 20 помилок:

```bash
sudo journalctl -p err -n 20 --no-pager
```

### 3.3 Запис про запуск/зупинку сервісу cron у журналах

```bash
sudo journalctl -u cron --no-pager
```

Пошук конкретно подій start/stop:

```bash
sudo journalctl -u cron | grep -E "Started|Stopped"
```

---

## Завдання 4. Створення власного сервісу (4 бали)

### 4.1 Створення bash-скрипта в домашньому каталозі

```bash
cat > ~/myscript.sh << 'EOF'
#!/bin/bash
LOG_FILE="$HOME/myscript.log"

while true; do
    date >> "$LOG_FILE"
    sleep 1
done
EOF

chmod +x ~/myscript.sh
```

Перевірка скрипта вручну (Ctrl+C для зупинки):

```bash
~/myscript.sh
# у іншому терміналі:
# tail -f ~/myscript.log
```

### 4.2 Створення файлу конфігурації сервісу

```bash
sudo tee /etc/systemd/system/myscript.service << EOF
[Unit]
Description=My custom script that writes date every second
After=network.target

[Service]
Type=simple
ExecStart=/home/$(whoami)/myscript.sh
Restart=always
RestartSec=3
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF
```

> Замініть `/home/$(whoami)/` на повний шлях до вашого домашнього каталогу, якщо потрібно.

### 4.3 Запуск сервісу та перевірка

```bash
sudo systemctl daemon-reload
sudo systemctl start myscript
sudo systemctl status myscript
sudo systemctl enable myscript
```

Перевірка, що дані записуються у файл:

```bash
sleep 3
tail -n 5 ~/myscript.log
```

Перегляд логів сервісу:

```bash
sudo journalctl -u myscript -n 10 --no-pager
```

### 4.4 (Опційно) Зупинка сервісу після перевірки

```bash
sudo systemctl stop myscript
sudo systemctl disable myscript
```

---

## Приклади виводу (з моєї системи)

### cron — статус

```
● cron.service - Regular background program processing daemon
     Loaded: loaded (/usr/lib/systemd/system/cron.service; enabled; preset: enabled)
     Active: active (running) since Sat 2026-05-30 19:51:04 CEST
```

### syslog — останні 10 рядків

```bash
cd /var/log && sudo tail -n 10 syslog
```

### journalctl — події cron (start/stop)

```
May 18 16:27:16 DESKTOP-TILGB75 systemd[1]: Stopped cron.service - Regular background program processing daemon.
May 18 16:27:32 DESKTOP-TILGB75 systemd[1]: Started cron.service - Regular background program processing daemon.
May 30 19:51:04 DESKTOP-TILGB75 systemd[1]: Started cron.service - Regular background program processing daemon.
```

### myscript.log — перевірка запису дати

```
Sat May 30 19:55:01 CEST 2026
Sat May 30 19:55:02 CEST 2026
Sat May 30 19:55:03 CEST 2026
Sat May 30 19:55:04 CEST 2026
Sat May 30 19:55:05 CEST 2026
```
