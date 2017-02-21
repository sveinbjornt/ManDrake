<img align="right" src="images/mandrake_icon.png" style="float: right; margin-left: 30px;" alt="ManDrake Application Icon">
# ManDrake

ManDrake is a native, open source <a href="https://en.wikipedia.org/wiki/Man_page">man page</a> editor for OS X. It has syntax highlighting, live <a href="https://en.wikipedia.org/wiki/Mandoc">`mandoc`</a> syntax validation and a live-updating rendered preview of the man page during editing.

Long story short, I was sick of writing man pages in an endless cycle of edit-view, edit-view so I decided to do something about it and made this editor. It's a bit rough around the edges, but it works really well for me.

* [Download ManDrake 3.1](http://sveinbjorn.org/files/software/mandrake/ManDrake-3.1.zip) (Intel 64-bit, 10.7 or later, ~1.9 MB)

To learn more about the man page format:

    man mdoc

or read [this page](http://www.freebsd.org/cgi/man.cgi?query=mdoc.samples).

## Screenshot

<img src="images/mandrake_screenshot.png" style="max-width:100%;" alt="ManDrake Screenshot">

## License

ManDrake is open source software, available under the three-clause BSD license:

> Copyright (c) 2004-2016, Sveinbjorn Thordarson &lt;sveinbjornt@gmail.com&gt;
> 
> Redistribution and use in source and binary forms, with or without modification,
> are permitted provided that the following conditions are met:
> 
> 1. Redistributions of source code must retain the above copyright notice, this
> list of conditions and the following disclaimer.
> 
> 2. Redistributions in binary form must reproduce the above copyright notice, this
> list of conditions and the following disclaimer in the documentation and/or other
> materials provided with the distribution.
> 
> 3. Neither the name of the copyright holder nor the names of its contributors may
> be used to endorse or promote products derived from this software without specific
> prior written permission.
> 
> THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
> ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
> WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
> IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
> INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
> PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
> WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
> ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
> POSSIBILITY OF SUCH DAMAGE.

## Building ManDrake

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

## Captain Mandrake

> **Do I look all rancid and clotted? You look at me, Jack. Eh? Look, eh? And I drink a lot of water, you know. I'm what you might call a water man, Jack - that's what I am. And I can swear to you, my boy, swear to you, that there's nothing wrong with my bodily fluids. Not a thing, Jackie.**

Here's **Group Captain Lionel Mandrake** from Kubrick's wonderful [*Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb*](http://www.imdb.com/title/tt0057012/) along with Brigadier General Jack D. Ripper, memorably rendered by Sterling Hayden:

<img src="images/mandrake_captain.jpg" alt="Group Captain Lionel Mandrake">
