## 0.2 Run scripts in ubuntu server from HomeAssistant

### 0.2.1 Create script and make it executable

mqtt_exec.sh
```
#!/bin/bash

# This script subscribes to a MQTT topic using mosquitto_sub.
# On each message received, you can execute whatever you want.
#JJ_Settings
mqtt_server="192.168.XXX.XXX"
mqtt_client="server"
mqtt_user="mqtt_user"
mqtt_pass="passwd"
mqtt_topic_cmd="server/cmd"
mqtt_topic_stat="server/stat"

sleep 10
mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "Booted" -d

echo "$(date +'%Y/%m/%d') - $(date +'%r') : System is booted" >> /opt/scripts/server_sys_log.txt

while true  # Keep an infinite loop to reconnect when connection lost/broker unavailable
do
    mosquitto_sub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_cmd |  while read -r payload
    do
        # Here is the callback to execute whenever you receive a message:
        echo "Rx MQTT: ${payload}"
        if [ $payload = "update_system" ]; then
            mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "Updating_Server..." -d
            # DEBIAN_FRONTEND=noninteractive apt update
            # DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
            # DEBIAN_FRONTEND=noninteractive apt autoremove -y
            echo "update system..."
            apt update
            apt full-upgrade -y
            apt autoremove -y
            mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "completed_system_update" -d
        elif [ $payload = "update_containers" ]; then
            mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "Updating_service(s)..." -d
            mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "Updated_ALL_containers" -d
        elif [ $payload = "restart_torrent" ]; then
            echo "cmd: restart gluetun and torrent"
            mosquitto_pub -h $mqtt_server -i $mqtt_client -u $mqtt_user -P $mqtt_pass -t $mqtt_topic_stat -m "Restarted Torrent" -d
        else
            echo "unknown cmd"
        fi
    done
    sleep 10  # Wait 10 seconds until reconnection
done # &   # Discomment the & to run in background (but you should rather run THIS script in background)

```

now, make it executable
```
sudo chmod 755 01_mqtt_exec.sh
```


### 0.2.2 edit crontab to run the script on boot

```
sudo crontab -e
```

add the line in the crontab
```
@reboot /opt/scripts/01_mqtt_exec.sh
```

update system.
```
#everyweek, Sunday 4am - update server linux
0 4 * * 0 sh /opt/scripts/50_update_linux.sh
```


### 0.2.3 mqtt client 설치

```
sudo apt-get install mosquitto-clients
```






