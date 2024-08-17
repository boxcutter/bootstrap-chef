# Ubuntu 22.04 Autoinstall

```
curl -LO https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso

docker run -it --rm \
  --mount type=bind,source="$(pwd)",target=/data \
  docker.io/boxcutter/ubuntu-autoinstall \
    -a autoinstall.yaml \
    -g grub.cfg
```

## Running tests

```
docker container run -t --rm \
    --mount type=bind,source="$(pwd)/test",target=/share \
    docker.io/boxcutter/cinc-auditor:6.8.1 exec . \
	  --backend=ssh \
	  --host=192.168.69.151 \
	  --user=automat \
	  --password=superseekret \
	  --no-create-lockfile
```
