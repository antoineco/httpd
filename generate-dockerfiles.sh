#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

nghttp2VersionDebian="$(docker run -i --rm centos:7 bash -c 'yum install -y https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm && yum info "$@"' -- 'nghttp2' |tac|tac| awk -F ': ' '$1 ~ /^Version/ { print $2; exit }')"
opensslVersionDebian="$(docker run -i --rm centos:7 bash -c 'yum install -y https://downloads.ulyaoth.net/rpm/ulyaoth-latest.centos.noarch.rpm && yum info "$@"' -- 'ulyaoth-openssl1.0.2' |tac|tac| awk -F ': ' '$1 ~ /^Version/ { print $2; exit }')"

for version in "${versions[@]}"; do
	fullVersion="$(curl -sSL --compressed "https://www.apache.org/dist/httpd/" | grep -E '<a href="httpd-'"$version"'[^"-]+.tar.bz2"' | sed -r 's!.*<a href="httpd-([^"-]+).tar.bz2".*!\1!' | sort -V | tail -1)"
	sha1="$(curl -fsSL "https://www.apache.org/dist/httpd/httpd-$fullVersion.tar.bz2.sha1" | cut -d' ' -f1)"
	(
		set -x
		sed -ri \
			-e 's/^(ENV HTTPD_VERSION) .*/\1 '"$fullVersion"'/' \
			-e 's/^(ENV HTTPD_SHA1) .*/\1 '"$sha1"'/' \
			-e 's/^(ENV NGHTTP2_VERSION) .*/\1 '"$nghttp2VersionDebian"'/' \
			-e 's/^(ENV OPENSSL_VERSION) .*/\1 '"$opensslVersionDebian"'/' \
			"$version"/*/Dockerfile
	)

done
