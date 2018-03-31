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

restart-eepsite: build-eepsite
	docker restart i2pgitea-eepsite
