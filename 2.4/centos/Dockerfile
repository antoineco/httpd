FROM centos:7

# ensure www-data user exists
RUN set -x \
	&& groupadd -g 48 -r www-data \
	&& useradd -u 48 -c "Apache" -s /sbin/nologin -M -r -g www-data www-data
# 82 is the standard uid/gid for "www-data" in CentOS
# https://git.centos.org/blob/rpms!!httpd/92bb46ca7c37ce73ddd26da323d0f24258980da8/SPECS!httpd.spec#L576

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:/usr/local/ulyaoth/openssl1.0.2/bin:$PATH
RUN mkdir -p "$HTTPD_PREFIX" \
	&& chown www-data:www-data "$HTTPD_PREFIX"
WORKDIR $HTTPD_PREFIX

# library for mod_http2
# mod_http2 requires a newer version of OpenSSL than centos:7 has available
ENV NGHTTP2_VERSION 1.21.1
ENV OPENSSL_VERSION 1.0.2l

# install httpd runtime dependencies
# https://httpd.apache.org/docs/2.4/install.html#requirements
RUN yum install -y \
	https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm \
	https://downloads.ulyaoth.net/rpm/ulyaoth-latest.centos.x86_64.rpm \
# disable EPEL and Ulyaoth repos by default
	&& yum-config-manager --disable epel ulyaoth \
	&& yum install -y \
		apr \
		apr-util \
		apr-util-ldap \
		apr-util-openssl \
		apr-devel \
		apr-util-devel \
		lua \
		perl \
		pcre \
		zlib \
	&& yum install -y --enablerepo epel \
		libnghttp2-$NGHTTP2_VERSION \
	&& yum install -y --enablerepo ulyaoth \
		ulyaoth-openssl1.0.2-libs-$OPENSSL_VERSION \
	&& yum clean all --enablerepo=epel,ulyaoth

ENV HTTPD_VERSION 2.4.25
ENV HTTPD_SHA1 bd6d138c31c109297da2346c6e7b93b9283993d2

# https://issues.apache.org/jira/browse/INFRA-8753?focusedCommentId=14735394#comment-14735394
ENV HTTPD_BZ2_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=httpd/httpd-$HTTPD_VERSION.tar.bz2
# not all the mirrors actually carry the .asc files :'(
ENV HTTPD_ASC_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2.asc

# see https://httpd.apache.org/docs/2.4/install.html#requirements
#     https://git.centos.org/blob/rpms!!httpd/92bb46ca7c37ce73ddd26da323d0f24258980da8/SPECS!httpd.spec#L143
RUN set -x \
	&& buildDeps=" \
		bzip2 \
		gcc \
		make \
		autoconf \
		findutils \
		xmlto \
		zlib-devel \
		lua-devel \
		pcre-devel \
		libxml2-devel \
	" \
	&& buildDepsEpel=" \
		libnghttp2-devel-$NGHTTP2_VERSION \
	" \
	&& buildDepsUlyaoth=" \
		ulyaoth-openssl1.0.2-devel-$OPENSSL_VERSION \
	" \
	&& yum install -y $buildDeps \
	&& yum install -y --enablerepo epel $buildDepsEpel \
	&& yum install -y --enablerepo ulyaoth $buildDepsUlyaoth \
	&& yum clean all --enablerepo=epel,ulyaoth \
	\
	&& curl -sSLo httpd.tar.bz2 "$HTTPD_BZ2_URL" \
	&& echo "$HTTPD_SHA1 *httpd.tar.bz2" | sha1sum -c - \
# see https://httpd.apache.org/download.cgi#verify
	&& curl -sSLo httpd.tar.bz2.asc "$HTTPD_ASC_URL" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys A93D62ECC3C8EA12DB220EC934EA76E6791485A8 \
	&& gpg --batch --verify httpd.tar.bz2.asc httpd.tar.bz2 \
	&& rm -r "$GNUPGHOME" httpd.tar.bz2.asc \
	\
	&& mkdir -p src \
	&& tar -xf httpd.tar.bz2 -C src --strip-components=1 \
	&& rm httpd.tar.bz2 \
	&& cd src \
	\
	&& ./configure \
		--prefix="$HTTPD_PREFIX" \
		--enable-mods-shared=reallyall \
		--with-ssl=/usr/local/ulyaoth/openssl1.0.2 \
	&& make -j "$(nproc)" \
	&& make install \
	\
	&& cd .. \
	&& rm -r src man manual \
	\
	&& sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		"$HTTPD_PREFIX/conf/httpd.conf" \
	\
	&& yum history -y rollback last-3 \
	&& find /etc -mindepth 2 -name *.rpmsave -exec rm -v '{}' + \
	&& rm -rf /var/tmp/*

COPY httpd-foreground /usr/local/bin/

EXPOSE 80
CMD ["httpd-foreground"]
