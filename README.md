Docker Zabbix
========================

## Container

The container provides the following *Zabbix Services*, please refer to the [Zabbix documentation](http://www.zabbix.com/) for additional info.

* A *Zabbix Server 2.2* at port 10051.
* A *Zabbix Web UI* at port 80 (username: `admin`, password: `zabbix`).
* A *Zabbix Agent*.
* A MySQL instance supporting *Zabbix*, user is `zabbix` and password is `zabbix`.
* A Monit daemon managing the processes (http://$container_ip:2812, user 'myuser' and password 'mypassword').

## Usage

You can run Zabbix as a service executing the following command.

```
docker run --name=zabbix \
			   -p 10051:10051 \
			   -p 80:80 \
			   -p 2812:2812 \
			   -v /var/lib/mysql:/var/lib/mysql \
			   -e GMAIL_USER=robot@gmail.com \
			   -e GMAIL_PASS=gmail_pa$$word \
keuz/zabbix
```

The above command will expose the *Zabbix Server* through port *10051* and the *Web UI* through port *80* on the host instance, among others.
Be patient, it takes a minute or two to configure the MySQL instance and start the proper services. You can tail the logs using `docker logs -f $container_id`.

Note: If you use Mysql on host you must specify separate volume for mysql data files.


## Mail notifications

To notifications via gmail:

* Pass `GMAIL_USER` and `GMAIL_PASS` variables to container.
* Add `mailalert.sh` as Script notification type to Media Types in Web UI, see: [Zabbix notifications  ](https://www.zabbix.com/documentation/2.2/manual/config/notifications/media/script).
* Configurate you gmail profile to allow `Access for less secure apps`.

**Attention**: 
Option `Access for less secure apps` is workaround and may be __potentially insecure__.
So it is *strongly recommended* to create a separate gmail box specially for notifications.

Current configuration of mail notification via `msmtp` not working without `Access for less secure apps`. It is issue. Spent some time to investigation of the problem, but it had not solved yet.





