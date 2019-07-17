# OpenSim Unix Grid Manager

Set of scripts and configuration for **OpenSim** 0.9.x to manage **Robust** and all **OpenSim** instances in a centralized way. Using a unique entry point with **tmux** and factorized initialization files, it becomes easier to create and upgrate a grid, and manage running simulators.

## Understanding directories

All the configuration is in the `config` directory and OpenSim provided initialization files are never touched. In fact the whole **Opensim** installation directory can be marked read-only to be sure it is not touched, and ready for an update.

OSGUM provided configuration files are in `lib/conf` directory, and should not be touched as well. Your configuration files are only in the `conf` directory to overload global settings.

Files created while instances are running are all in the `run` directory. One directory per **OpenSim** instance, plus the **Robust** one.

**OpenSim** downloaded binaries are in the `opensim` directory. It is possible to use difference versions of **OpenSim** for each instance and **Robust**, or use the same everywhere. It is very flexible :)

## Binaries

All commands are in the `bin` directory. The simpliest way to run your grid, once it is configured, is to run the `bin/gridctl` script, which starts **Robust** and all enabled **OpenSim** instances. **Robust** and **OpenSim** instances can also be controlled separately via `bin/robustctl` and `bin/simctl` respectively.

## Configuration

The main settings for the grid are stored in the `conf/osgum.conf` file. It's a bash script defining some variables used globally.

### conf/available/

This directory contains one directory per configured **OpenSim** instance.

### conf/enabled/

This directory is a set of symlinks to the `conf/available/` directory for each enabled **OpenSim** instance. `bin/gridctl` will use those symlinks to know which instances to manage with the grid as a whole.

### Local settings

OSUGM provides its own configuration files that should not be touched.
You can finegrain alter settings with those in the `conf` directory:

* `conf/osgum.conf` your OSGUM main configuration file
* `conf/Robust.ini` your local **Robust** settings
* `conf/Robust.exe.config` logging options
* `conf/OpenSim.ini` your local simulator settings, shared for all instances
* `conf/available/{inst}/instance.conf` local overrides from `conf/osgum.conf` (for example, to use a specific **OpenSim** version)
* `conf/available/{inst}/Local.ini` your local simulator settings for a specific instance
* `conf/available/{inst}/OpenSim.exe.config` logging options
* `conf/available/{inst}/regions/*.ini` region initialization files

### Global settings

Among files you should never touch, here is a description to have a sight on how things are organized.

For **Robust**:
* `lib/conf/Robust.ini` main configuration file, includes your `conf/Robust.ini`
* `lib/conf/Robust.exe.config` used if `conf/Robust.exe.config` does not exist

For **OpenSim**:
* `lib/conf/OpenSim.ini` main configuration file for all instances
* `lib/conf/OpenSim.exe.config` used if `conf/available/{inst}/OpenSim.exe.config` does not exist

