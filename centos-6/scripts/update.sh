#!/bin/bash
set -eo pipefail

repo="centos"
dir="$(readlink -f "$(dirname "$BASH_SOURCE")/../build")"
arch='amd64'
distrib='centos-6'
version='6'
mirror='http://mirror.centos.org/centos-6/6/os/x86_64/Packages'
latest=''

mkdir -p "$dir"
cd "$dir"

args=( -d "$dir" rinse --cache=0)
[ -z "$arch" ] || args+=( --arch="$arch" )
[ -z "$distrib" ] || args+=( --distribution="$distrib" )
[ -z "$mirror" ] || args+=( --mirror="$mirror" )

wget -N http://anonscm.debian.org/cgit/collab-maint/rinse.git/plain/etc/centos-6.packages
args+=( --pkgs-dir="." )

rinseVersion="$(rinse --version)"
rinseVersion="${rinseVersion##* }"

mkimage="$(readlink -f "../scripts/mkimage.sh")"
{
	echo "$(basename "$mkimage") ${args[*]/"$dir"/.}"
	echo
	echo 'https://github.com/docker/docker/blob/master/contrib/mkimage.sh'
} > "$dir/build-command.txt"

sudo nice ionice -c 3 "$mkimage" "${args[@]}" 2>&1 | tee "$dir/build.log"

sudo chown -R "$(id -u):$(id -g)" "$dir"

if [ "$repo" ]; then
	( set -x && docker build -t "${repo}:${version}" "$dir" )
	docker run -it --rm "${repo}:${version}" bash -xc '
		cat /etc/yum.repos.d/CentOS-Base.repo
		echo
		cat /etc/redhat-release 2>/dev/null
		echo
		cat /etc/centos-release 2>/dev/null
		true
	'
	docker run --rm "${repo}:${version}" yum list installed > "$dir/build.manifest"
fi

if [ "$latest" ]; then
	( set -x && docker tag -f "${repo}:${latest}" "${repo}:latest" )
fi
