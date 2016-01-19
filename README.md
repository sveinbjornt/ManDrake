# ManDrake

<img align="right" src="https://raw.githubusercontent.com/sveinbjornt/ManDrake/master/mandrake.png" style="float: right; margin-left: 30px;">

ManDrake is a native, open-source man page editor for OS X. It has syntax highlighting and a live-updating rendered preview of the man page.

Long story short, I was sick of writing man pages in an endless cycle of edit-view, edit-view so I decided to do something about it and made this editor. It's a bit rough around the edges, but it works really well for me.

You can download a pre-built binary of version 2.2 here: [Download ManDrake (Intel 64-bit)](http://sveinbjorn.org/files/software/mandrake/ManDrake-2.2.zip) (~660KB, 10.7 or later).

## License

ManDrake is distributed under the [GNU General Public License v2](https://www.gnu.org/licenses/gpl.txt)

## Development

### Requirements

If you want to build ManDrake yourself, you need the following components/tools:

* a recent version of Xcode with support for ARC and subscripting
* OS X SDK (10.7 or later)
* Git

You may also need to install Xcode’s command line tools with the following command, if you want to re-build the included `cat2html`:

    xcode-select --install

### Environment Setup

After cloning the repository, run the following commands inside the repository root (directory containing this `README.md` file):

    git submodule init
    git submodule update
