
WD := $(shell pwd)

update: update-gogs

passwd:
	apg -a 1 -m 15 -x 20 -n 1 -M CL > passwd

config:
	cp -R $(HOME)/.ssh $(WD)/../.ssh
	sed '0,/PASSWD =/s/PASSWD =/PASSWD =/' app.ini | tee app.custom.ini
	#sed '0,/PASSWD =/s/PASSWD =/PASSWD = $(shell cat passwd)/' app.ini | tee app.custom.ini


install: config update

network:
	docker network create i2pgit; true

build-gogs:
	docker build --force-rm -f Dockerfiles/Dockerfile.gogs -t eyedeekay/i2pgogs .

run-gogs: network
	docker run -d --name i2pgogs \
		--network i2pgit \
		--network-alias i2pgogs \
		--hostname i2pgogs \
		-p 127.0.0.1:3000:3000 \
		--volume $(WD)/sqlite:/var/sqlite \
		--volume /etc/ssh:/etc/ssh \
		--volume $(WD)/../.ssh:/var/lib/gogs/.ssh \
		eyedeekay/i2pgogs

clean-gogs:
	docker rm -f i2pgogs; true

update-gogs:
	git pull
	make clean-gogs build-gogs run-gogs

log-gogs:
	docker logs -f i2pgogs

