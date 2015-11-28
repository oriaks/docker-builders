#!/bin/bash

repo="true"
dir="$(readlink -f "$(dirname "$BASH_SOURCE")/build")"

mkdir -p "$dir"
cd "$dir"

if which nasm && `nasm -o true ../src/true.asm` && [ -f true ]; then
	true
elif which gcc && `gcc -Os -o true -static ../src/true.c` && [ -f true ]; then
	true
else
	exit 1
fi

chmod +x true

echo >&2 "+ cat > '$dir/Dockerfile'"
cat > "$dir/Dockerfile" <<EOF
FROM scratch
ADD true /
CMD ["/true"]
EOF

if [ "$repo" ]; then
	( set -x && docker build -t "${repo}:latest" "$dir" )
	docker run -it --rm "${repo}:latest" /true
fi
