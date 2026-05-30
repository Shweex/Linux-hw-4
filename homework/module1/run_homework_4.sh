#!/bin/bash
# Скрипт для швидкого виконання ДЗ №4 у WSL/Linux
# Запуск: bash run_homework_4.sh

set -e

echo "========== Завдання 1: Менеджери пакетів =========="
sudo apt update
sudo apt install -y tree
dpkg -l tree
tree --version
sudo apt remove -y tree
dpkg -l tree || true

echo ""
echo "========== Завдання 2: systemctl (cron) =========="
systemctl status cron --no-pager || true
sudo systemctl stop cron
systemctl is-active cron || true
sudo systemctl start cron
systemctl is-active cron
sudo systemctl enable cron
systemctl is-enabled cron

echo ""
echo "========== Завдання 3: Логи =========="
cd /var/log
sudo tail -n 10 syslog
sudo journalctl -p err -n 20 --no-pager
sudo journalctl -u cron | grep -E "Started|Stopped"

echo ""
echo "========== Завдання 4: Власний сервіс =========="
cat > ~/myscript.sh << 'SCRIPT'
#!/bin/bash
LOG_FILE="$HOME/myscript.log"
while true; do
    date >> "$LOG_FILE"
    sleep 1
done
SCRIPT
chmod +x ~/myscript.sh

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

sudo systemctl daemon-reload
sudo systemctl start myscript
sudo systemctl status myscript --no-pager
sudo systemctl enable myscript
sleep 3
tail -n 5 ~/myscript.log
sudo journalctl -u myscript -n 10 --no-pager

echo ""
echo "========== Готово! =========="
