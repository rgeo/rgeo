# Enable GEOS and Proj4 on Heroku

If you need GEOS and PROJ extensions on Heroku, you need to install those libraries through a buildpack.

## Option 1: Use [heroku-buildpack-apt]

**TL;DR**

```bash
echo 'libgeos-dev=3.7.1-1~pgdg18.04+1' > Aptfile # Use the version you want here
echo 'libproj-dev' >> Aptfile                    # Same here, you can not pin any version as well.
echo >> Aptfile
git add Aptfile
git commit -m 'Add Aptfile'
heroku buildpacks:add --index=1 heroku-community/apt

# If you already have installed the gem earlier, you will need to purge your repo cache.
# Hence the next two lines:
heroku plugins:install heroku-repo
heroku repo:purge_cache

git push heroku main
```

[heroku-buildpack-apt](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt) is an official buildpack supported by Heroku.

You need to create a file called `Aptfile` at the root of your repository with the following content:

```
libproj-dev
libgeos-dev
```

You should also consider specifying the version to make sure it changes only if you want it. For instance for libgeos:

```
libgeos-dev=3.7.1-1~pgdg18.04+1
```

Then you just need to add the [heroku-buildpack-apt] at the proper position:

```
$ heroku buildpacks:add --index 1 heroku-community/apt
```

If your Heroku environment has a config variable named `LD_LIBRARY_PATH`, please unset that.

It is also really likely that you have the rgeo gem beforehand, in which case you will need to purge your application cache:

```bash
heroku plugins:install heroku-repo
heroku repo:purge_cache
```

You can finally deploy to heroku and check if everything is alright!

Ref: http://www.diowa.com/blog/heroku/2017/08/01/using-rgeo-with-geos-on-heroku-with-apt-get

## Option 2: Use [heroku-buildpack-vendorbinaries]

Apt packages often contain older version of the libraries, so you may be interested in something
newer or in compiling the master branch by yourself.

You can find latest GEOS and PROJ binaries built for Heroku at [Vesuvius: a Vulcan replacement](https://vesuvius.herokuapp.com/)

Then you can use [heroku-buildpack-vendorbinaries] buildpack, which is very similar to `heroku-buildpack-apt`.

The example provided at [heroku-buildpack-vendorbinaries' readme](https://github.com/diowa/heroku-buildpack-vendorbinaries#example), contains information about this very same use case.

Ref: http://www.diowa.com/blog/heroku/2017/08/01/compile-libraries-on-heroku-with-vesuvius

## Option 3: Use [heroku-geo-buildpack]

This is the simplest method, but it also installs `gdal`, which is not used by RGeo. Just install the buildpack as usual and purge your repo if RGeo was already installed.

```bash
heroku buildpacks:add --index=1 https://github.com/heroku/heroku-geo-buildpack.git
heroku plugins:install heroku-repo
heroku repo:purge_cache
```

## Check that geos is correctly installed

```bash
heroku console <<< 'puts "RGeo is configured with Geos !" if RGeo::Geos.capi_supported?;exit'
```

Note that checking `RGeo::Geos.supported?` might be misleading since this would also return `true` if `geos-ffi` is installed. Since the CAPI and FFI do not have the same behavior, it is important to check which one you have and prefer the CAPI when possible.

[heroku-buildpack-apt]: https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt
[heroku-buildpack-vendorbinaries]: https://github.com/diowa/heroku-buildpack-vendorbinaries
[heroku-geo-buildpack]: https://github.com/heroku/heroku-geo-buildpack
