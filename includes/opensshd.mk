build-opensshd:
	docker build --force-rm -f Dockerfiles/Dockerfile.opensshd -t eyedeekay/i2pgitea-opensshd .

run-opensshd: network
	docker run -d --name i2pgitea-opensshd \
		--network i2pgit \
		--network-alias i2pgitea-opensshd \
		--hostname i2pgitea-opensshd \
		--link i2pgitea \
		--restart always \
		-v $(WD)/ssh:/usr/share/gitea/.ssh \
		eyedeekay/i2pgitea-opensshd

clean-opensshd:
	docker rm -f i2pgitea-opensshd; true

update-opensshd:
	git pull
	make clean-opensshd build-opensshd run-opensshd

log-opensshd:
	docker logs -f i2pgitea-opensshd

restart-opensshd: build-opensshd
	docker restart i2pgitea-opensshd
