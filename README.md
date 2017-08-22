# Supported tags and respective `Dockerfile` links

* `2.2.34-centos`, `2.2-centos` [(2.2/centos/Dockerfile)](https://github.com/antoineco/httpd/blob/94751d53f2a8025cce4e7c0eb1074b8ac11224ea/2.2/centos/Dockerfile)
* `2.4.27-centos`, `2.4-centos`, `2-centos`, `centos` [(2.4/centos/Dockerfile)](https://github.com/antoineco/httpd/blob/518a18780bf95e4fdc1cc67d8feb41214032155c/2.4/centos/Dockerfile)

![logo](https://raw.githubusercontent.com/antoineco/httpd/master/logo.png)

# What is the `httpd` image?

An extension of the official [`httpd`][docker-httpd] image with extra OS variants.

# How to use the `httpd` image?

This image shares all its features with the official [`httpd`][docker-httpd] image.

# Image Variants

The `httpd` images come in different flavors, each designed for a specific use case.

## Base operating system

### `httpd:<version>-centos`

This image is based on the [CentOS](https://www.centos.org/) operating system, available in [the `centos` official image][docker-centos].

## Components

A tagging convention determines the version of the components distributed with the `httpd` image.

### `<version α>`

* Httpd release: **α**

# Maintenance

## Updating configuration

You can automatically update OpenJDK versions and regenerate the repository tree with:

```
./generate-dockerfiles.sh
```

## Updating library definition

After committing changes to the repository, regenerate the library definition file with:

```
./generate-bashbrew-library.sh >| httpd
```

## Rebuilding images

All images in this repository can be rebuilt and tagged manually using [Bashbrew][bashbrew], the tool used for cloning, building, tagging, and pushing the Docker official images. To do so, simply call the `bashbrew` utility, pointing it to the included `httpd` definition file as in the example below:

```
bashbrew --library . build httpd
```

## Automated build pipeline

Any push to the upstream [`centos`][docker-centos] repository or to the source repository triggers an automatic rebuild of all the images in this repository. From a high perspective the automated build pipeline looks like the below diagram:

![Automated build pipeline][pipeline]


[banner]: https://raw.githubusercontent.com/antoineco/httpd/master/logo.png
[docker-httpd]: https://hub.docker.com/_/httpd/
[docker-centos]: https://hub.docker.com/_/centos/
[bashbrew]: https://github.com/docker-library/official-images/blob/master/bashbrew/README.md
[pipeline]: https://raw.githubusercontent.com/antoineco/httpd/master/build_pipeline.png
