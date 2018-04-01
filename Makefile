
WD := $(shell pwd)
USERNAME := $(USER)
PASSWORD := $(shell apg -a 1 -m 10 -x 15 -n 1 -M CL)

include config.mk

site: update-gitea

update: update-gitea update-dropbear update-eepsite

suggest-password:
	echo "$(USERNAME):$(PASSWORD)" | tee suggest-password

config: suggest-password
	cp gitea.ini app.custom.ini
	sed -i 's|changeme|$(shell apg -m 50 -n 1 -a |)|g' app.custom.ini

install: update-dropbear update-eepsite update-gitea

network:
	docker network create i2pgit; true

include includes/gitea.mk
include includes/dropbear.mk
include includes/eepsite.mk

clean: clean-eepsite clean-gitea clean-dropbear

clobber: clean reset-ssh reset-db
	sudo rm -rf ./gitea/*

curl:
	curl -x 127.0.0.1:4444 http://dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

surf:
	http_proxy=http://127.0.0.1:4444 surf http://dwfxipghufoij7c3wwhgesttaooxeu6plwv3rqx3av3gyfkhduhq.b32.i2p

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
	echo '#! /usr/bin/env sh' | tee i2p-socks-proxy
	echo 'connect-proxy -S 127.0.0.1:4447 -R remote $$*' | tee -a i2p-socks-proxy
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

nuke:
	sudo rm -rf gitea gogs sqlite ssh passwd suggest-password
	docker rmi -f eyedeekay/i2pgitea eyedeekay/i2pgitea-dropbear eyedeekay/i2pgitea-eepsite; true
