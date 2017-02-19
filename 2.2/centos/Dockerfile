FROM centos:7

# ensure www-data user exists
RUN set -x \
	&& groupadd -g 48 -r www-data \
	&& useradd -u 48 -c "Apache" -s /sbin/nologin -M -r -g www-data www-data
# 82 is the standard uid/gid for "www-data" in CentOS
# https://git.centos.org/blob/rpms!!httpd/92bb46ca7c37ce73ddd26da323d0f24258980da8/SPECS!httpd.spec#L576

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH
RUN mkdir -p "$HTTPD_PREFIX" \
	&& chown www-data:www-data "$HTTPD_PREFIX"
WORKDIR $HTTPD_PREFIX

# install httpd runtime dependencies
# https://httpd.apache.org/docs/2.2/install.html#requirements
RUN yum install -y \
		apr \
		apr-util \
		apr-util-ldap \
		apr-util-openssl \
		apr-devel \
		apr-util-devel \
		perl \
		pcre \
		zlib \
		openssl-libs \
	&& yum clean all

ENV HTTPD_VERSION 2.2.32
ENV HTTPD_SHA1 36dc7f2ac97627192dcff0a121408b897f91b121

# https://issues.apache.org/jira/browse/INFRA-8753?focusedCommentId=14735394#comment-14735394
ENV HTTPD_BZ2_URL https://www.apache.org/dyn/closer.cgi?action=download&filename=httpd/httpd-$HTTPD_VERSION.tar.bz2
# not all the mirrors actually carry the .asc files :'(
ENV HTTPD_ASC_URL https://www.apache.org/dist/httpd/httpd-$HTTPD_VERSION.tar.bz2.asc

# see https://httpd.apache.org/docs/2.2/install.html#requirements
#     https://git.centos.org/blob/rpms!!httpd/92bb46ca7c37ce73ddd26da323d0f24258980da8/SPECS!httpd.spec#L143
RUN set -x \
	\
	&& buildDeps=" \
		bzip2 \
		gcc \
		make \
		autoconf \
		findutils \
		zlib-devel \
		pcre-devel \
		openssl-devel \
	" \
	&& yum install -y $buildDeps \
	&& yum clean all \
	\
	&& curl -sSLo httpd.tar.bz2 "$HTTPD_BZ2_URL" \
	&& echo "$HTTPD_SHA1 *httpd.tar.bz2" | sha1sum -c - \
# see https://httpd.apache.org/download.cgi#verify
	&& curl -sSLo httpd.tar.bz2.asc "$HTTPD_ASC_URL" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B1B96F45DFBDCCF974019235193F180AB55D9977 \
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
# https://httpd.apache.org/docs/2.2/programs/configure.html
# Caveat: --enable-mods-shared=all does not actually build all modules. To build all modules then, one might use:
		--enable-mods-shared='all ssl ldap cache proxy authn_alias mem_cache file_cache authnz_ldap charset_lite dav_lock disk_cache' \
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
	&& yum history -y undo last \
	&& find /etc -mindepth 2 -name *.rpmsave -exec rm -v '{}' +

COPY httpd-foreground /usr/local/bin/

EXPOSE 80
CMD ["httpd-foreground"]
