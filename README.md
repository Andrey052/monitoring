# Monitoring Task (Bash + systemd)

Этот проект представляет собой тестовое задание:  
скрипт для мониторинга процесса `test` в Linux + systemd unit + systemd timer.

---

## Функциональность

Скрипт делает следующее:

1. Каждый запуск — раз в минуту — выполняется через `systemd timer`.
2. Проверяет, запущен ли процесс `test`.
3. Если процесс запущен:
   - отправляет HTTPS-запрос на `https://test.com/monitoring/test/api`
   - если запрос не прошёл — пишет в лог.
4. Если PID процесса изменился — фиксирует перезапуск в логе.
5. Логи записываются в:

/var/log/monitoring.log

---

## Структура проекта

monitoring-task/
│
├── scripts/
│ └── test-monitor.sh # скрипт
│
├── systemd/
│ ├── test-monitor.service # systemd unit
│ └── test-monitor.timer # systemd timer
│
├── examples/
│ └── fake-test-process.sh # тестовый процесс
│
└── README.md

---

## Установка

### 1. Установка зависимостей

sudo apt update
sudo apt install -y curl procps

### 2. Установка скрипта

sudo cp scripts/test-monitor.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/test-monitor.sh

### 3. Установка systemd unit и timer

sudo cp systemd/test-monitor.service /etc/systemd/system/
sudo cp systemd/test-monitor.timer /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now test-monitor.timer

### Запуск тестового процесса

chmod +x examples/fake-test-process.sh
./examples/fake-test-process.sh &

## Проверка работы
Проверить логи:

sudo tail -n 20 /var/log/monitoring.log

Проверить статус таймера:

systemctl status test-monitor.timer

Ручной запуск мониторинга:

sudo systemctl start test-monitor.service