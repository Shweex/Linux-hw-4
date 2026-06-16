# Домашнє завдання. Модуль 5 — Мережа, SSH та копіювання файлів

**ПІБ:** Дубіцький Владислав Васильович  
**ОС/дистрибутив:** Ubuntu (WSL2)  
**Дата виконання:** 16.06.2026

---

## Завдання 1. Мережева діагностика (2 бали)

### 1.1 IP-адреси та інтерфейси

**Команда:**

```bash
ip a
```

**Вивід (фрагмент):**

```text
1: lo: <LOOPBACK,UP,LOWER_UP> ...
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 172.28.55.251/20 brd 172.28.63.255 scope global eth0
```

**Коментар:** Локальна IP-адреса основного мережевого інтерфейсу `eth0` — **172.28.55.251**. Також присутній loopback-інтерфейс `lo` з адресою 127.0.0.1.

---

### 1.2 Перевірка доступності публічного вузла

**Команда:**

```bash
ping 8.8.8.8
```

**Вивід (фрагмент):**

```text
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=25.7 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=34.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=38.4 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=27.3 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
```

**Коментар:** Усі 4 пакети отримано без втрат — **доступ до інтернету є**.

---

### 1.3 Відкриті listening-порти

**Команда:**

```bash
ss -tulpn
```

**Вивід (фрагмент):**

```text
Netid State  Recv-Q Send-Q  Local Address:Port Peer Address:Port Process
tcp   LISTEN 0      4096    127.0.0.53%lo:53        0.0.0.0:*
tcp   LISTEN 0      4096       127.0.0.54:53        0.0.0.0:*
tcp   LISTEN 0      1000   10.255.255.254:53        0.0.0.0:*
tcp   LISTEN 0      4096                *:2222            *:*
```

**Коментар:** Приклад сервісу, що слухає порт: **systemd-resolved (DNS) на порту 53** (`127.0.0.53:53`). Також видно SSH-сервер на порту **2222** (тестовий сервер для завдань 2–3).

**Підсумок завдання 1:**
- Локальна IP: **172.28.55.251** (інтерфейс `eth0`)
- Інтернет: **доступний**
- Сервіс на порту: **systemd-resolved (DNS, порт 53)**

---

## Завдання 2. SSH-доступ з ключами та config (4 бали)

### 2.1 Генерація SSH-ключа

**Команда:**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

**Вивід:**

```text
256 SHA256:ZHFSG1lbrXR0QA1NbPxOHXJr3zPx/osHHuPxqp5gYgY shweex@DESKTOP-TILGB75 (ED25519)
```

**Коментар:** Створено пару ключів ED25519 у `~/.ssh/id_ed25519` без парольної фрази.

---

### 2.2 Копіювання ключа на сервер

**Команда:**

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 shweex@127.0.0.1
```

**Вивід:**

```text
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/shweex/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: WARNING: All keys were skipped because they already exist on the remote system.
```

**Коментар:** Публічний ключ успішно додано на сервер (повторне виконання показує, що ключ уже на місці).

---

### 2.3 Налаштування `~/.ssh/config`

**Команда:**

```bash
nano ~/.ssh/config
```

**Вміст файлу:**

```text
Host myserver
    HostName 127.0.0.1
    User shweex
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking accept-new
```

**Коментар:** Додано Host-запис `myserver` з іменем хоста, користувачем, портом і шляхом до приватного ключа.

---

### 2.4 Підключення короткою командою

**Команда:**

```bash
ssh myserver
```

**Вивід:**

```text
Connected without password
b241f1163fa2
shweex
/config
```

**Коментар:** Підключення через `ssh myserver` працює; пароль **не запитується** (автентифікація за ключем).

---

### 2.5 Перевірка входу без пароля

**Команда:**

```bash
ssh -o BatchMode=yes myserver "echo OK"
```

**Вивід:**

```text
SSH OK without password
b241f1163fa2
shweex
```

**Коментар:** Режим `BatchMode=yes` забороняє інтерактивний ввід пароля — підключення пройшло успішно, отже **вхід без пароля працює**.

**Підсумок завдання 2:**
- Ім'я Host у config: **myserver**
- Підключення без пароля: **так, працює**

---

## Завдання 3. Копіювання файлів між машинами (4 бали)

### 3.1 Створення локального тестового файлу

**Команда:**

```bash
echo "test" > test.txt
```

**Вивід:**

```text
test
```

**Коментар:** Локально створено файл `test.txt` з вмістом `test`.

---

### 3.2 Передача файлу на сервер через scp

**Команда:**

```bash
scp test.txt myserver:/config/
```

**Вивід (фрагмент):**

```text
Transferred: sent 4496, received 5156 bytes, in 0.0 seconds
debug1: Exit status 0
```

**Коментар:** Файл `test.txt` успішно скопійовано на сервер у каталог `/config/`.

---

### 3.3 Створення директорії для синхронізації на сервері

**Команда:**

```bash
ssh myserver "mkdir -p /config/sync_dir"
```

**Вивід (фрагмент `ls -la /config`):**

```text
drwxr-xr-x 2 shweex users 4096 Jun 16 19:54 sync_dir
-rw-r--r-- 1 shweex users    5 Jun 16 19:54 test.txt
```

**Коментар:** На сервері створено директорію `/config/sync_dir` для синхронізації.

---

### 3.4 Синхронізація локальної папки через rsync

**Команди:**

```bash
mkdir -p sync_local
echo "sync1" > sync_local/file1.txt
echo "sync2" > sync_local/file2.txt
rsync -avz sync_local/ myserver:/config/sync_dir/
```

**Вивід:**

```text
sending incremental file list
file1.txt
file2.txt

sent 202 bytes  received 54 bytes  512.00 bytes/sec
total size is 12  speedup is 0.05
```

**Коментар:** Локальна папка `sync_local/` синхронізована з `/config/sync_dir/` на сервері; передано 2 файли.

---

### 3.5 Перевірка файлів через sftp

**Команда:**

```bash
sftp myserver
```

**Команди всередині sftp:**

```text
ls -la /config
ls -la /config/sync_dir
bye
```

**Вивід:**

```text
sftp> ls -la /config
-rw-r--r--    ? shweex   users           5 Jun 16 21:54 /config/test.txt
drwxr-xr-x    ? shweex   users        4096 Jun 16 21:54 /config/sync_dir
sftp> ls -la /config/sync_dir
-rw-r--r--    ? shweex   users           6 Jun 16 21:54 /config/sync_dir/file1.txt
-rw-r--r--    ? shweex   users           6 Jun 16 21:54 /config/sync_dir/file2.txt
```

**Коментар:** Через SFTP підтверджено наявність `test.txt` та файлів `file1.txt`, `file2.txt` у директорії синхронізації.

**Підсумок завдання 3:**
- Шлях до файлів на сервері: **`/config/test.txt`**, **`/config/sync_dir/`**
- Команда перевірки: **`sftp myserver`** → `ls -la /config` та `ls -la /config/sync_dir`
