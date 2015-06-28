# ManDrake

ManDrake is a native, open-source man page editor for Mac OS X. It has syntax highlighting and live-updating rendered preview.

Long story short, I was sick of writing man pages in an endless cycle of edit-view, edit-view so I decided to do something about it and made this editor. It's a bit rough around the edges, but it works really well for me.

Visit the [project site](http://sveinbjorn.org/mandrake) for more information. 

## License

The source code is distributed under the [GNU General Public License v2](http://sveinbjorn.org/license

## Development

### Requirements

If you wish to build ManDrake yourself, you will need the following components/tools:

* a recent Xcode with support for ARC and subscripting
* OS X SDK (10.6 or later)
* Git

You may also need to install Xcode’s command line tools with the following command, if you want to re-build the included `cat2html`:

    xcode-select --install

### Environment Setup

After cloning the repository, run the following commands inside the repository root (directory containing this `README.md` file):

    git submodule init
    git submodule update
