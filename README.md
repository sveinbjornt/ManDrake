<img align="right" src="https://raw.githubusercontent.com/sveinbjornt/ManDrake/master/mandrake.png" style="float: right; margin-left: 30px;">
# ManDrake

ManDrake is a native, open-source <a href="https://en.wikipedia.org/wiki/Man_page">man page</a> editor for OS X. It has `groff` syntax highlighting, `mandoc` syntax validation and shows a live-updating rendered preview of the man page during editing.

Long story short, I was sick of writing man pages in an endless cycle of edit-view, edit-view so I decided to do something about it and made this editor. It's a bit rough around the edges, but it works really well for me.

You can download a pre-built binary of version 3.0 here: 

* [Download ManDrake 3.0](http://sveinbjorn.org/files/software/mandrake/ManDrake-3.0.zip) (Intel 64-bit, 10.7 or later, ~660 KB)

## License

ManDrake is distributed under the three-clause [BSD License](https://opensource.org/licenses/BSD-3-Clause).

## Screenshot

<img src="https://raw.githubusercontent.com/sveinbjornt/ManDrake/master/mandrake_screenshot.png" style="max-width:100%;">

## Development

### Requirements

If you want to build ManDrake yourself, you need the following components/tools:

* a recent version of Xcode with support for ARC and subscripting
* OS X SDK (10.7 or later)
* Git
* [CocoaPods](https://cocoapods.org)

You may also need to install Xcode’s command line tools with the following command, if you want to re-build the included `cat2html` and `mandoc` binaries 

    xcode-select --install

### Environment Setup

After cloning the repository, run the following commands inside the repository root (i.e. the directory containing this `README.md` file):

    pod install

This installs all the dependencies required.
