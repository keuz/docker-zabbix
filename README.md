Docker Zabbix
========================

## Container

The container provides the following *Zabbix Services*, please refer to the [Zabbix documentation](http://www.zabbix.com/) for additional info.

* A *Zabbix Server* at port 10051.
* A *Zabbix Web UI* at port http://zabbix.dv.ru
* A *Zabbix Agent*.
* A MySQL instance supporting *Zabbix*, user is `zabbix` and password is `zabbix`.
* A Monit deamon managing the processes (http://$container_ip:2812, user 'myuser' and password 'mypassword').

## Usage

You can run Zabbix as a service executing the following command.

```
docker run -d \
           -p 10051:10051 \
           -p 80:80       \
           -p 2812:2812   \
           dentavita/zabbix
```

The above command will expose the *Zabbix Server* through port *10051* and the *Web UI* through port *80* on the host instance, among others.
Be patient, it takes a minute or two to configure the MySQL instance and start the proper services. You can tail the logs using `docker logs -f $contaienr_id`.

After the container is ready the *Zabbix Web UI* should be available at `http://zabbix.dv.ru`. User is `admin` and password is `zabbix`.
