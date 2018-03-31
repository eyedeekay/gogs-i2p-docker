
WD := $(shell pwd)
USERNAME := $(USER)
PASSWORD := $(apg -a 1 -m 15 -x 20 -n 1 -M CL)

site: update-gitea

update: config upgate-dropbear update-eepsite update-gitea local

suggest-password:
	echo "$(USERNAME):$(PASSWORD)" >> suggest-password

config: suggest-password fix-perms
	cp gitea.ini app.custom.ini
	sed -i 's|changeme|$(shell apg -m 50 -n 1)|g' app.custom.ini

install: config update

network:
	docker network create i2pgit; true

build-gitea:
	docker build --force-rm -f Dockerfiles/Dockerfile.gitea -t eyedeekay/i2pgitea .

run-gitea: network
	docker run -d --name i2pgitea \
		--network i2pgit \
		--network-alias i2pgitea \
		--hostname i2pgitea \
		-p 127.0.0.1:3000:3000 \
		--restart always \
		--volume $(WD)/sqlite:/var/sqlite \
		--volume $(WD)/gitea:/var/lib/gitea/ \
		eyedeekay/i2pgitea

clean-gitea:
	docker rm -f i2pgitea; true

update-gitea:
	git pull
	make clean-gitea build-gitea run-gitea

log-gitea:
	docker logs -f i2pgitea

build-eepsite:
	docker build --force-rm \
		-f Dockerfiles/Dockerfile.eepsite \
		-t eyedeekay/i2pgitea-eepsite .

run-eepsite: network
	docker run -d --name i2pgitea-eepsite \
		--network i2pgit \
		--network-alias i2pgitea-eepsite \
		--hostname i2pgitea-eepsite \
		--expose 4567 \
		--link i2pgitea-dropbear \
		--link i2pgitea-dropbear \
		-p :4567 \
		-p 127.0.0.1:7076:7076 \
		--volume $(WD)/i2pd:/var/lib/i2pd:rw \
		--restart always \
		eyedeekay/i2pgitea-eepsite

clean-eepsite:
	docker rm -f i2pgitea-eepsite; true

update-eepsite:
	git pull
	make clean-eepsite build-eepsite run-eepsite

log-eepsite:
	docker logs -f i2pgitea-eepsite

build-dropbear:
	docker build --force-rm -f Dockerfiles/Dockerfile.dropbear -t eyedeekay/i2pgitea-dropbear .

run-dropbear: network
	docker run -d --name i2pgitea-dropbear \
		--network i2pgit \
		--network-alias i2pgitea-dropbear \
		--hostname i2pgitea-dropbear \
		--expose 4567 \
		--link i2pgitea \
		--restart always \
		eyedeekay/i2pgitea-dropbear

clean-dropbear:
	docker rm -f i2pgitea-dropbear; true

update-dropbear:
	git pull
	make clean-dropbear build-dropbear run-dropbear

log-dropbear:
	docker logs -f i2pgitea-dropbear

clean: clean-eepsite clean-gitea clean-dropbear

clobber: clean reset-ssh reset-db
	sudo rm -rf ./gitea/*

surf:
	http_proxy=http://127.0.0.1:4444 surf dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

test-clone:
	http_proxy=http://127.0.0.1:4444 git clone http://dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p/eyedeekay/test

test-commit:
	touch README.md && git add . && git commit -am "test"

test-push:
	cd test; http_proxy=http://127.0.0.1:4444 git push

firefox:
	firefox http://dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

local:
	surf http://127.0.0.1:3000

i2p-socks-proxy:
	echo 'connect-proxy -S 127.0.0.1:s -R remote $$*' > i2p-socks-proxy
	chmod +x i2p-socks-proxy

install-bin: i2p-socks-proxy
	sudo install -m755 i2p-socks-proxy /usr/bin/i2p-socks-proxy
	git config --global core.gitproxy i2p-socks-proxy

clean-session:
	sudo rm -rf gitea/data

reset-ssh:
	sudo rm -rf ./ssh/* ./sshd/*

reset-db:
	sudo rm -rf ./sqlite/*

mon:
	docker exec --user root i2pgitea ps aux

fix-perms:
	sudo mkdir -p ssh sqlite gitea gitea/data gitea/tmp gitea/archive gitea/avatars
	sudo chown -R 101:102 ssh sqlite gitea
	sudo chmod -R o+rw ssh sqlite gitea

nuke:
	sudo rm -rf gitea gogs sqlite ssh passwd suggest-password
