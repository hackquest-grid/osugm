# OpenSim Unix Grid Manager

Set of scripts and configuration for **OpenSim** 0.9.x to manage one **Robust** and all **OpenSim** instances in a centralized way. Using a unique entry point with **screen** and factorized initialization files, it becomes easier to create and upgrade a grid, and manage running simulators.

You just need the `osugm` script to create your grid (**Robust**) and **OpenSim** instances, run and stop them. Without any argument, it will show a short usage help.

You also need only one **OpenSim** distribution for **Robust** and all instances of **OpenSim**.


## Two ways of working

**OSUGM** can work in two types of setup:
* One dedicated directory for itself and the running **OpenSim** (it is how it works out of the box)
* Unix standard directories layout (the *install* command does this)

### Dedicated directory layout

* `bin`: contains the unique `osugm` script, entry point for all commands
* `conf`: your local grid configuration
* `lib`: **OSUGM** helper scripts, configuration and templates
* `runners`: downloaded distributions of **OpenSim**
* `data`: where content files will be placed by **OpenSim** and **Robust**, as well as log files

### Unix layout

As the tool is extremely configurable, it's just a set of variables making it pointing to various directories (see the reference at the end of this document).

Everything is related to a *{prefix}* directory (could be `/usr`, `/usr/local`, `/opt` or any other you would want).

When you install **OSUGM**, you can give a *name* to the prefix, so that any occurrence of `osugm` is replaced by `osugm.{name}`. That makes it possible to install several instances of **OSUGM** for various needs. In the following listing, `{osugm}` refers to that (with or without the `.{name}` suffix)

* `{prefix}/bin`: contains the unique `{osugm}` script, entry point for all commands
* `{prefix}/etc/{osugm}`: your local grid configuration
* `{prefix}/lib/{osugm}`: **OSUGM** helper scripts, configuration and templates
* `{prefix}/var/lib/{osugm}`: downloaded distributions of **OpenSim**
* `{prefix}/var/log/{osugm}`: log files from **OSUGM**, **OpenSim** and **Robust**
* `{prefix}/var/run/{osugm}`: where content files will be placed by **OpenSim** and **Robust**



## Download and extract Opensim

You need of course at least one distribution of **OpenSim** available in the `opensim` directory (or any other directory if you changed `$OSUGM_EXEC`, see below for custom directories). Download the one you need, extract it in the `opensim` directory, ensuring the distribution respects the standard Opensim schema (everything contained in a `bin` directory).

```sh
$ cd path/to/osugm
$ cd opensim
$ tar -axf path/to/downloaded/opensim-0.9.2.0.tar.xz
$ ls opensim-0.9.2.0
addon-modules
bin
doc
...
```



## Init grid configuration

```sh
$ bin/osugm init
```
Run this to create the initial directories and files for your grid. Then you have to edit files generated in the `conf` directory.

### osugm.conf

It's a shell script that will be sourced by **OSUGM**, and contains global settings for the grid. First the mandatory variables:
* **OSUGM_LOGGING**: if `true` all commands played will be logged into log files (same than what is shown in the console without colors)
* **OSUGM_NAME**: your grid nickname, aka. short name without spaces
* **OSUGM_FULLNAME**: display name of the grid, defaults to the same than **OSUGM_NAME**
* **OSUGM_HOST**: the public hostname hosting the grid. By default it is the result of the `hostname` command, but you probably need to use a public DNS name, and make an entry in your `/etc/hosts` to point that name to your local IP address
* **OSUGM_SCHEME**: keep it to `http` for now, **OSUGM** has not been tested yet with TLS. The variable is provided for future enhancements
* **OSUGM_PUBLICPORT**: the publicly available port used to contact your grid (historically, it's `8002`)
* **OSUGM_PRIVATEPORT**: the port for internal communication between **Robust** and simulators (historically, it's `8003`)

Then you have global defaults, that can be overriden by simulator instances:
* **OSUGM_DOTNET**: path to the **dotnet** binary to use (defaults to the first `dotnet` executable found in the `PATH`)
* **OSUGM_OPENSIM**: path to the default **OpenSim** distribution, used by **Robust** and all simulator instances, in dedicated directory setup, this path is relative to the `runners` directory, in Unix setup, it is relative to `/var/lib/{osugm}`

* ***shell commands***: any shell command that can modify the environment can be added

> Considering network access, **OSUGM** does not provide any facility to configure your computer or router for incoming requests. You will surely have to configure your router to open ports and play with `iptables` or `nft` to enable NAT forwarding.

### Database.ini

This file is included by **Robust** global configuration, and defines how to connect to the grid database. Refer to **Robust** documentation to provide the right settings here.

> **OSUGM** does not provide any facility to create and manage your database, you have to create it yourself.

### Robust.ini

This file is included by **Robust** global configuration, and is where you define custom settings for your grid. It is included at the very end of configuration loading, so you can override anything pre-configured by **OSUGM** (global configuration is in `lib/conf/Robust.ini`)



## Run your grid

Once you have edited your configuration files, you can test it:
```sh
$ bin/osugm start
info Robust starting . running
```

That will start **Robust** and all *enabled* simulator instances (see below for simulators)

**OSUGM** starts process in the background, using **screen** to keep console access. So once processes are started, it returns immediately. To reach the **Robust** console, execute
```sh
$ bin/osugm robust console
```

> Once in the console, type `Ctrl-A D` to exit without stopping **Robust**. Check **screen** documentation (`man 1 screen`) if you are not used to it.

If you need to start **Robust** directly (without using **screen**), you can execute
```sh
$ bin/osugm robust direct
```

All files gerenated by **Robust** are stored in the `data/grid` directory (`/var/run/{osugm}/grid` for Unix install). That means anything you are used to see in the `bin` directory of **OpenSim** is put there for **Robust**.



## Stop your grid

As simple as
```sh
$ bin/osugm stop
```

That will stop all *enabed* simulators and then **Robust**.



## Create a simulator instance

**OSUGM** can manage several **OpenSim** instances running alongsie **Robust**. Like the grid, **OSUGM** has it's own default configuration that you can override in your `conf` directory. You don't need to install several **OpenSim** for each instance, nothing is written in the distribution so it is reusable for all instances if needed (but you can have more than one **OpenSim** distribution installation, and choose which one to use for each instance)

Each instance needs a name (without space or special characters). Those names are freely chosen, except you cannot use *grid* or *robust* (that makes sense too).

Let's define a *welcome* instance name, that will host our welcome land:
```sh
$ osugm sim init welcome
```

It tells you that configuration has been generated in the `conf/available/welcome` directory.

## Instance configuration


### available and enabled

Each instance has its own configuration directory, under `conf/available/{instancename}`.

Until they are explicitely enabled, those instances are not run automatically when the grid starts.
```sh
$ bin/osugm sim enable {instancename}
```
This creates a link for the instance configuration in the `conf/enabled` directory. This is this directory that **OSUGM** reads when operating at grid level.

This is a nice way to include or exclude simulator instances from the grid. Of course even when not enabled, an instance can be started individually with a `osugm sim {command} {instancename}` command (see below for more details).

### instance.conf

This is the equivalent to `osugm.conf`, dedicated to this instance of **OpenSim**.

You can for example change **shell** and **Mono** settings, and override some global variables, like `$OSUGM_OPENSIM` to use a specific **OpenSim** distribution.

The most important variable to setup is `OSUGM_SIMPORT`. It represents the HTTP port used by **OpenSim** to listen on. It will be used to set the `http_listener_port` of the `[Network]` section of **OpenSim** configuration.

### Local.ini and *.ini

`Local.ini` is empty by default, but will be included for **OpenSim** after all others. You can put your custom settings there. In fact, you can add as many `.ini` files as you want in the `conf` directory, they will all be read.

### regions directory

Under the instance configuration directory, you will find a `regions` directory. `Regions.ini` files will be stored in this directory when you will create your first region in **OpenSim**.

### conf/OpenSim.ini

This file is out of the instance configuration directory. This is one you can customize and is read by all instances of **OpenSim**, making shared configuration easier. By default, it sets up the simulator database connector (a simple SQLite database in the runtime directory).




## Running a simulator instance

To start manually a simulator instance, execute (replace `{instancename}` with the actual simulator instance name)
```sh
$ bin/osugm sim start {instancename}
info {instancename} starting . running
```

Like for **Robust**, you can get the console with
```sh
$ bin/osugm sim console {instancename}
```
You should there see the **OpenSim** prompt to create a region. Refer to **OpenSim** documentation for this. Just be sure:
* to use a DNS hostname publicly accessible from internet for the **External Hostname**, or the public IP if a DNS is not possible
* set an **Internal Port** that is opened for UDP on incoming requests

A last step: your grid needs a default region. So in `conf/Robust.ini` change the commented line to match your region name:
```ini
[GridService]

    Region_Welcome = "DefaultRegion, FallbackRegion"
```

To stop the simulator, simply do
```sh
$ bin/osugm sim stop {instancename}
{instancename} stopping. stopped
```

Like for **Robust**, you can also start the simulator without **sreen**:
```sh
$ bin/osugm sim direct {instancename}
```



## Enable the instance on the grid

To start the simulator instance with the grid, you must enable it:
```
$ bin/osugm sim enable {instancename}
```

Next run of `osugm start` will start **Robust** and your simulator instance.



## Internal configuration

**OSUGM** provides its own configuration files that should not be touched.
You can finegrain alter settings with those in your `conf` directory.

For **Robust**:
* `lib/conf/Robust.ini` main configuration file, includes your `conf/Robust.ini` and `conf/Database.ini`
* `lib/conf/Robust.exe.config` used if `conf/Robust.exe.config` does not exist

For **OpenSim**:
* `lib/conf/OpenSim.ini` main configuration file for all instances, includes your `conf/OpenSim.ini` and uses `conf/available/{inst}` directory as modular configuration (parsing all `.ini` in it)
* `lib/conf/OpenSim.exe.config` used if `conf/available/{inst}/OpenSim.exe.config` does not exist

### Datas directory

The `data` directory contains all *variable* files and directories. It's organized per instance:
* `data/grid` contains **Robust** runtime files
* `data/opensim.{instance}` (with *{instance}* the instane name) contains all **OpenSim** runtime files for one instance



## Directories and variables

### Default layout

**OSUGM** distribution is made of 2 classic directories:
* `bin` contains the `osugm` command
* `lib` content needed by scripts

Other directories are generated during the setup. By default, **OSUGM** is configured to be in its own directory, using it as a root for user files. By exporting some variables it's possible to give it references to other directories:
* `OSUGM_BIN` **OSUGM** command, defaults to `bin`
* `OSUGM_CONF` where your configuration is, defaults to `conf`
* `OSUGM_LIB` a different directory for **OSUGM** support files, defaults to `lib`
* `OSUGM_LOG` where log files are put, defaults to `data`
* `OSUGM_EXEC` where Opensim releases are put, defaults to `opensim`
* `OSUGM_DATA` data directory (your grid/opensim user files), defaults to `data`

If you follow **OSUGM** updates, you can easily update copies.
Let's say you have a copy in `/opt/mygrid`, you can copy the update with a simple
```sh
$ bin/osugm copy /opt/mygrid
```

### Using the Unix directory layout

Let's say you want to install **OSUGM** the standard way, in `/usr/local`:
```sh
(root)$ bin/osugm install /usr/local
```

That will create on your system:
* `/usr/local/bin/osugm` script
* `/usr/local/etc/osugm/` (overrides **OSUGM_CONF**)
* `/usr/local/etc/osugm/.std` (flag file to point to tell **OSUGM** to point to the right Unix standard diretories)
* `/usr/local/lib/osugm/` (overrides **OSUGM_LIB**)
* `/usr/local/var/lib/osugm/` (overrides **OSUGM_EXEC**)
* `/usr/local/var/log/osugm/` (overrides **OSUGM_LOG**)
* `/usr/local/var/run/osugm/` (overrides **OSUGM_DATA**)

If prefix is `/usr`, installation is a bit different, considering it's a global system install:
* `/usr/bin/osugm` script
* `/etc/osugm/` for **OSUGM_CONF**
* `/etc/osugm/.std` flag file
* `/usr/lib/osugm/` for **OSUGM_LIB**
* `/var/lib/osugm/` for **OSUGM_EXEC**
* `/var/log/osugm/` for **OSUGM_LOG**
* `/var/run/osugm/` for **OSUGM_DATA**

If you want to host several instances of **OSUGM** on the same system, you can also specify an alternate *name* that will be used as a suffix. Let's install in `/usr` with the name `mygrid`:
```sh
(root)$ bin/osugm install /usr mygrid
```
This will create:
* `/usr/bin/osugm.mygrid` script
* `/etc/osugm.mygrid/` (**OSUGM_CONF**)
* `/etc/osugm.mygrid/.std` flag file
* `/usr/lib/osugm.mygrid/` (**OSUGM_LIB**)
* `/var/lib/osugm.mygrid/` (**OSUGM_EXEC**)
* `/var/log/osugm.mygrid/` (**OSUGM_LOG**)
* `/var/run/osugm.mygrid/` (**OSUGM_DATA**)
