#!/bin/bash
set -eo pipefail

repo="debian"
dir="$(readlink -f "$(dirname "$BASH_SOURCE")/../build")"
variant='minbase'
components='main'
include=''
suite='jessie'
mirror='http://httpredir.debian.org/debian'
script=''
latest='jessie'

mkdir -p "$dir"
cd "$dir"

args=( -d "$dir" debootstrap )
[ -z "$variant" ] || args+=( --variant="$variant" )
[ -z "$components" ] || args+=( --components="$components" )
[ -z "$include" ] || args+=( --include="$include" )

debootstrapVersion="$(debootstrap --version)"
debootstrapVersion="${debootstrapVersion##* }"
if dpkg --compare-versions "$debootstrapVersion" '>=' '1.0.69'; then
	args+=( --force-check-gpg )
fi

args+=( "$suite" )
if [ "$mirror" ]; then
	args+=( "$mirror" )
	if [ "$script" ]; then
		args+=( "$script" )
	fi
fi

mkimage="$(readlink -f "../scripts/mkimage.sh")"
{
	echo "$(basename "$mkimage") ${args[*]/"$dir"/.}"
	echo
	echo 'https://github.com/docker/docker/blob/master/contrib/mkimage.sh'
} > "$dir/build-command.txt"

sudo nice ionice -c 3 "$mkimage" "${args[@]}" 2>&1 | tee "$dir/build.log"

sudo chown -R "$(id -u):$(id -g)" "$dir"

if [ "$repo" ]; then
	( set -x && docker build -t "${repo}:${suite}" "$dir" )
	if [ "$suite" != "$version" ]; then
		( set -x && docker tag "${repo}:${suite}" "${repo}:${version}" )
	fi
	docker run -it --rm "${repo}:${suite}" bash -xc '
		cat /etc/apt/sources.list
		echo
		cat /etc/os-release 2>/dev/null
		echo
		cat /etc/lsb-release 2>/dev/null
		echo
		cat /etc/debian_version 2>/dev/null
		true
	'
	docker run --rm "${repo}:${suite}" dpkg-query -f '${Package}\t${Version}\n' -W > "$dir/build.manifest"

	if [ "${backports[$suite]}" ]; then
		mkdir -p "$dir/backports"
		echo "FROM $origRepo:$suite" > "$dir/backports/Dockerfile"
		cat >> "$dir/backports/Dockerfile" <<-'EOF'
			RUN awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/backports.list
		EOF
	fi
fi

if [ "$latest" ]; then
	( set -x && docker tag -f "${repo}:${latest}" "${repo}:latest" )
fi
