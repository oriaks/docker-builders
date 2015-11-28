# oriaks/docker-builders

These are scripts to build our base images for Docker at Oriaks.

## Requirements

- [Docker](https://www.docker.com/)
- [debootstrap](https://wiki.debian.org/Debootstrap/)
- [rinse](http://collab-maint.alioth.debian.org/rinse/)
- [nasm](http://www.nasm.us/)

## How to use

```console
git clone https://github.com/oriaks/docker-builders.git
cd docker-builders/debian-jessie
./build.sh
```

## ToDo

- Use [Packer](https://packer.io/)

## See also

- [docker/docker](https://github.com/docker/docker)
- [docker-library/official-images](https://github.com/docker-library/official-images)
- [tianon/dockerfiles](https://github.com/tianon/dockerfiles)
- [tianon/docker-brew-debian](https://github.com/tianon/docker-brew-debian)
- [CentOS/sig-cloud-instance-build](https://github.com/CentOS/sig-cloud-instance-build)
- [CentOS/sig-cloud-instance-images](https://github.com/CentOS/sig-cloud-instance-images)
