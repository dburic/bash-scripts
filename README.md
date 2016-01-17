Shell scripts
======================================================================

This is a collection of shell scripts. The scripts have been developed,
tested and used with Bash on Linux, so they may not work with other shells
or systems.

Licence
------------------------------

This software is distributed under the MIT license. See LICENSE for
details.

Installation
------------------------------

[Yruba](http://www.pifpafpuf.de/Yruba/), a build system for Bash by 
[Harald Kirsch](http://www.pifpafpuf.de/), is needed for installation. Perl
is also required (although, this dependency could be easily removed).

The installation procedure will overwrite files without asking, so be
careful.

Choose an installation directory, say `/usr/local`, and modify the variable
`LIBDIR` in `head.sh` so that it points to `/usr/local/lib/bash`. After
that, simply do the following:

    yruba prepare
    sudo PREFIX=/usr/local yruba install

If you have chosen `$HOME` as your installation directory, then you don't
have to edit `head.sh`, just call yruba:

    yruba prepare
    yruba install

Executable files are copied to `$PREFIX/bin`, while libraries are copied to
`$PREFIX/lib/bash`.

