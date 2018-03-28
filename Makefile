
WD := $(shell pwd)
USERNAME := gogs
PASSWORD := $(apg -a 1 -m 15 -x 20 -n 1 -M CL)

site: update-gogs

update: clean-eepsite update-gogs
	make local; true
	make update-eepsite

suggest-password:
	echo "gogs:$(PASSWORD)" >> suggest-password
	cp app.ini app.custom.ini

config: suggest-password

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
		-p 127.0.0.1:2222:2222 \
		--volume $(WD)/sqlite:/var/sqlite \
		--volume $(WD)/gogs:/var/lib/gogs/ \
		--volume $(WD)/sshd_config:/etc/ssh/sshd_config \
		eyedeekay/i2pgogs

clean-gogs:
	docker rm -f i2pgogs; true

update-gogs:
	git pull
	make clean-gogs build-gogs run-gogs

log-gogs:
	docker logs -f i2pgogs

build-eepsite:
	docker build --force-rm -f Dockerfiles/Dockerfile.eepsite -t eyedeekay/i2pgogs-eepsite .

run-eepsite: network
	docker run -d --name i2pgogs-eepsite \
		--network i2pgit \
		--network-alias i2pgogs-eepsite \
		--hostname i2pgogs-eepsite \
		--expose 4567 \
		--link i2pgogs \
		-p :4567 \
		-p 127.0.0.1:7076:7076 \
		--volume $(WD)/i2pd:/var/lib/i2pd:rw \
		--restart always \
		eyedeekay/i2pgogs-eepsite

clean-eepsite:
	docker rm -f i2pgogs-eepsite; true

update-eepsite:
	git pull
	make clean-eepsite build-eepsite run-eepsite

log-eepsite:
	docker logs -f i2pgogs-eepsite

clean: clean-eepsite clean-gogs

clobber: clean
	rm -rf gogs sqlite

surf:
	http_proxy=http://127.0.0.1:4444 surf dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

firefox:
	firefox http://dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

local:
	surf http://127.0.0.1:3000
