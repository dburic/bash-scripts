# Bash scripts

This is a collections of Bash scripts to support specific command-line
workflows. The scripts are developed, tested and used mostly on Linux.

## License

This software is distributed under the MIT license. See LICENSE for details.

## List of scripts

- jump      - quickly jump to a directory
- kwstart   - quickly start a file or URL via keyword
- notes     - manage text notes
- onevim    - edit files using only one Vim instance
- par       - wrapper around xargs to allow easy execution of parallel jobs
- rem       - remember location of files for later use
- srename   - sequentially rename files
- start     - a file and URL starter/launcher
- zipdir    - archive contents of directories

## Installation

Execute the following command:

    ./setup install

This will copy all scripts to `~/.local/bin`, and `common.sh` to `~/.local/lib/bash-scripts`.

The `--prefix` option can be used to change `~/.local` to something else:

    ./setup install --prefix=$HOME

## Configuration

By default, the scripts look for their config files in `~/.config/bash-scripts`.

Examples of config files can be found in the `doc` directory.

## Usage

Each script has a `--help` switch, which will print a help message with a
summary of the purpose of the script, a usage statement, a more elaborate
description, a list of available commands and options, and some examples.

