# symsym Crashreport Desymbolizer for Mac OS X

symsym is a tool for Mac OS X that allows to de-symbolize crashlogs.

### Install

    sudo gem install symsym

## Usage

symsym will look for a dSYM bundle that matches the bundle identifier, version and short version string found in the crashreport. It will run gdb to desymbolize the addresses in the given crashlog.
The crashlog can be read from a file or from the Mac OS X pasteboard.
Output can be to a file, the OS X pasteboard or stdout

Use symsym from the command line:

* -i read crashreport from given file
* -o write de-symbolized crashreport to given file
* -p read crashreport from pasteboard
* -c write de-symbolized crashreport to pasteboard
* -d The path where symsym will look for a matching .dSYM bundle - and of course in all subfolders of this path

So when you want to replace the crashreport in your pasteboard with the de-symbolized version, go to a directory that contains your dSYM bundles, type

    symsym -p -c

and you are done!

_Note:_ gdb needs the application bundle next to the dSYM bundle to be able to desymbolize the crashlog.

## Issues/TODO

* Read the architecture from the crashreport

## Contribute

* fork me on Github - [https://github.com/sononum/symsym](https://github.com/sononum/symsym)
* send a pull request

## Copyright

Copyright (c) 2011 Ulrich Zurucker. See LICENSE.txt for further details.