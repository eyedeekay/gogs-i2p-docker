build-gitea:
	docker build --force-rm \
		-f Dockerfiles/Dockerfile.gitea \
		-t eyedeekay/i2pgitea .

run-gitea: config network
	docker run -d --name i2pgitea \
		--network i2pgit \
		--network-alias i2pgitea \
		--hostname i2pgitea \
		--env="username=$(shell sed 's|:.*||g' suggest-password)" \
		--env="password=$(shell sed 's|$(USER):||g' suggest-password)" \
		-p 127.0.0.1:3000:3000 \
		--restart always \
		--volume $(WD)/sqlite:/var/sqlite \
		--volume $(WD)/gitea:/var/lib/gitea \
		--volume $(WD)/ssh:/var/lib/gitea/.ssh \
		eyedeekay/i2pgitea

#--mount type=volume,src=$(WD)/sqlite,dst=/var/sqlite \
#--mount type=volume,src=$(WD)/gitea,dst=/var/lib/gitea \

clean-gitea:
	docker rm -f i2pgitea; true

update-gitea:
	git pull
	make clean-gitea build-gitea run-gitea

log-gitea:
	docker logs -f i2pgitea

restart-gitea: build-gitea
	docker restart i2pgitea
