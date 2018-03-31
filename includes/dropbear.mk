build-dropbear:
	docker build --force-rm -f Dockerfiles/Dockerfile.dropbear -t eyedeekay/i2pgitea-dropbear .

run-dropbear: network
	docker run -d --name i2pgitea-dropbear \
		--network i2pgit \
		--network-alias i2pgitea-dropbear \
		--hostname i2pgitea-dropbear \
		--link i2pgitea \
		--restart always \
		-v $(WD)/ssh:/usr/share/gitea/.ssh \
		eyedeekay/i2pgitea-dropbear

clean-dropbear:
	docker rm -f i2pgitea-dropbear; true

update-dropbear:
	git pull
	make clean-dropbear build-dropbear run-dropbear

log-dropbear:
	docker logs -f i2pgitea-dropbear

restart-dropbear: build-dropbear
	docker restart i2pgitea-dropbear
