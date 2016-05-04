
Follow the docker install instructions at https://docs.docker.com/engine/installation/linux/ubuntulinux/.

<h3> LANL Notes </h3>

Must add HTTP proxy information when accessing the key-server.

 ````
sudo apt-key adv --keyserver-options http-proxy=http://proxyout.lanl.gov:8080 --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
````

Must configure LANL docker proxies.

export http_proxy=http://proxyout.lanl.gov:8080/
export https_proxy=http://proxyout.lanl.gov:8080/
export all_proxy=http://proxyout.lanl.gov:8080/

source /etc/environment



and for docker. from http://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy


First, create a systemd drop-in directory for the docker service:

mkdir /etc/systemd/system/docker.service.d
Now create a file called /etc/systemd/system/docker.service.d/http-proxy.conf that adds the HTTP_PROXY environment variable:

[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80/"
If you have internal Docker registries that you need to contact without proxying you can specify them via the NO_PROXY environment variable:

Environment="HTTP_PROXY=http://proxy.example.com:80/"
Environment="NO_PROXY=localhost,127.0.0.0/8,docker-registry.somecorporation.com"
Flush changes:

$ sudo systemctl daemon-reload
Verify that the configuration has been loaded:

$ sudo systemctl show docker --property Environment
Environment=HTTP_PROXY=http://proxy.example.com:80/
Restart Docker:

$ sudo systemctl restart docker




And in Redhat

Docker in Centos7

set proxy in /etc/yum.conf
````
proxy=http://proyout.lanl.gov:8080/
````
set proxy in /etc/profile.d/proxy.sh (use shell settings)
````
proxy=http://proyout.lanl.gov:8080/
````
set proxy for docker



