### Description

Goal of this project is to simplify usage of ergogen and ergogen-gui with custom footprints.


### Rationale

* notoriously hard to use custom footprints with ergogen
* online available hosted ergogen-gui sites not always are up-to-date with latest ergogen version
* impossible to use online available ergogen-gui for preview if custom footprints are used

Additionally you will not polute local environment with packages since all moving parts are hidden in docker images.

Also you'll get `./fetch-footprints.sh` tool to manage custom footprints.


### TL;DR

If short on time or for fast start skip to Summary section.


#### Preparation

Create required folders:

```sh
mkdir input/ output/
```


Fetch essential footprints:

```sh
./fetch-footprints.sh --add-vanilla
```


Copy your keyboard description where ergogen expects to find it:

```sh
cp PATHTO/your-awesome-keyboard-layout.yaml input/keyboard.yaml
```

(or you could just link it with `ln -s`).


#### Run ergogen locally in Docker 

This should speed up keyboard development a bit.

With some shell magik you can re-open KiCAD with fresh scheme on every change in `keyboard.yaml`.

`./make-cli.sh build` will build Docker image.

`./make-cli.sh run` will generate keyboard files from ergogen's keyboard description. 

Your keyboard description should be placed in `input/` folder and named `keyboard.yaml`

`./make-cli.sh run` will run ergogen with sane defaults and place output files into `output/` folder.

But you can override default behaviour (see `extras.cli/docker-entrypoint.sh` for default command if curious) and supply own arguments for ergogen to run.

For example, `./make-cli.sh run -h` is identical to running `ergogen -h` and will show help message for ergogen.

`./make-cli.sh` will take care of lots of stuff for you,
in particular it will mount all required folders and rebuild ergogen inside docker image to accommodate all changes in `footprints/` folder
so any new or changed footprints will be in effect on every ergogen invocation.


#### Run ergogen-gui locally in Docker

When you developing keyboard layout and want to leverage ergogen-gui's preview capability
it is convenient to run it locally.

First, run `./make-gui.sh build` to build Docker image.
Then, run `./make-gui.sh daemon` to run ergogen-gui in background.
Web interface will be available at `http://localhost:3000`.

`./make-gui.sh run` is same as `daemon` only console will be attached so you can see logs if you want to.
Generally you don't need that.

Every time `footprints/` folder is changed you need to run `./make-gui.sh sync` to refresh image with new footprints.
But this should not be happening very often during layout developing phase.


#### Working with custom footprints

This is interesting part.

Basically now you can supply any footprints to ergogen to work with.
The way it works is we overriding footprints folder inside ergogen installation inside Docker container.

Since whole `footprint` folder is overwritten we have to supply original footprints ergogen bundled with.

Here is where `./fetch-footprints.sh` comes into play.

It can do bunch of things:
* download vanilla ergogen footprints
* download footprints from any git repo (you can specify path inside repo for footprints folder)
* fetch footprints from local folder
* generate `index.js` with all footprints present inside `footprints/` folder

Run `./fetch-footprints.sh -h` for options reminder.
Run `./fetch-footprints.sh --help` for detailed usage, options description and examples.

For basic usage `./fetch-footprints.sh --add-vanilla` will be enough.

Every time `footprints/` folder is changed we need to sync it with ergogen inside Docker container.

When working with ergogen `./make-cli.sh run` will take care of it for you.

When working with ergogen-gui you need to run `./make-gui.sh sync` every time you make changes to content of `footprints/` folder.


### Summary

#### ergogen

```sh
mkdir input/ output/
./fetch-footprints.sh --add-vanilla
cp PATHTO/your-awesome-keyboard-layout.yaml input/keyboard.yaml
./make-cli.sh build
./make-cli.sh run
find output/
```

#### ergogen-gui

```sh
./fetch-footprints.sh --add-vanilla
./make-gui.sh build
./make-gui.sh daemon
open localhost:3000
```

Every time `footprints` folder is changed run:

```sh
./make-gui.sh sync
```

### Notes

Dockerfiles are currently using my own ergogen and ergogen-gui repos
until my fixes are merged into upstreams.

