# Telebot service

To set up the service copy the script to the `init.d` directory and make all necessary scripts executable:

```bash
sudo cp /root/docs_markup_bot/scripts/telebot_service.sh /etc/init.d/run_telebot
sudo chmod +x /etc/init.d/run_telebot
sudo chmod +x /root/docs_markup_bot/scripts/run_telebot.sh

# Make the service restart after the server is rebooted
sudo update-rc.d run_telebot defaults
```

The server should be used like this:

```bash
sudo service run_telebot [start|stop|restart|status]
```

The service runs our `scripts/run_telebot.sh` script which calls the telebot rake task

Set up log rotation:

```bash
sudo touch /var/log/run_telebot.log
sudo chown root /var/log/run_telebot.log

sudo nano /etc/logrotate.conf
```

Insert the following settings to the very end of the `logrotate.conf`:

```
/var/log/run_telebot.log {
  daily
  missingok
  rotate 7
  compress
  delaycompress
  notifempty
  copytruncate
}
```
