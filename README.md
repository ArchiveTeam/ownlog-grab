ownlog-grab
==========

More information about the archiving project can be found on the [ArchiveTeam wiki page for the project](http://archiveteam.org/index.php?title=Ownlog.com)! This is phase 2.

Timing is not critical (no shutdown date yet) so keep 1-2 threads per IP to keep the service stable.



Setup instructions
=========================

Be sure to replace `YOURNICKHERE` with the nickname that you want to be shown as, on the tracker. You don't need to register it, just pick a nickname you like.

In most of the below cases, there will be a web interface running at http://localhost:8001/. If you don't know or care what this is, you can just ignore it - otherwise, it gives you a fancy view of what's going on.

**If anything goes wrong while running the commands below, please scroll down to the bottom of this page - there's troubleshooting information there.**

Running with a warrior
-------------------------

Follow the [instructions on the ArchiveTeam wiki](http://archiveteam.org/index.php?title=Warrior) for installing the Warrior, and select the "Hyves" project in the Warrior interface.

To run this outside the warrior, clone this repository and run:

    pip install seesaw
    ./get-wget-lua.sh

then start downloading with:

    run-pipeline pipeline.py --concurrent 2 YOURNICKHERE

For more options, run:

    run-pipeline --help
    
Running multiple instances on different IPs
-------------------------------------------

This feature requires seesaw version 0.0.16 or greater. Use `pip install --upgrade seesaw` to upgrade.

Use the `--context-value` argument to pass in `bind_address=123.4.5.6` (replace the IP address with your own).

Example of running 2 threads, no web interface, and Wget binding of IP address:

    run-pipeline pipeline.py --concurrent 2 YOURNICKHERE --disable-web-server --context-value bind_address=123.4.5.6


Distribution-specific setup
-------------------------
### For Debian/Ubuntu:

    adduser --system --group --shell /bin/bash archiveteam
    apt-get install -y git-core libgnutls-dev lua5.1 liblua5.1-0 liblua5.1-0-dev screen python-dev python-pip bzip2 zlib1g-dev
    pip install seesaw
    su -c "cd /home/archiveteam; git clone https://github.com/ArchiveTeam/hyves-grab.git; cd hyves-grab; ./get-wget-lua.sh" archiveteam
    screen su -c "cd /home/archiveteam/hyves-grab/; run-pipeline pipeline.py --concurrent 2 --address '127.0.0.1' YOURNICKHERE" archiveteam
    [... ctrl+A D to detach ...]
    
### For CentOS:

Ensure that you have the CentOS equivalent of bzip2 installed as well. You might need the EPEL repository to be enabled.

    yum -y install gnutls-devel lua-devel python-pip zlib-devel
    pip install seesaw
    [... pretty much the same as above ...]

### For openSUSE:

    zypper install liblua5_1 lua51 lua51-devel screen python-pip libgnutls-devel bzip2 python-devel gcc make
    pip install seesaw
    [... pretty much the same as above ...]

### For OS X:

You need Homebrew. Ensure that you have the OS X equivalent of bzip2 installed as well.

    brew install python lua gnutls
    pip install seesaw
    [... pretty much the same as above ...]

**There is a known issue with some packaged versions of rsync. If you get errors during the upload stage, hyves-grab will not work with your rsync version.**

This supposedly fixes it:

    alias rsync=/usr/local/bin/rsync

### For Arch Linux:

Ensure that you have the Arch equivalent of bzip2 installed as well.

1. Make sure you have `python-pip2` installed.
2. Install [https://aur.archlinux.org/packages/wget-lua/](the wget-lua package from the AUR). 
3. Run `pip2 install seesaw`.
4. Modify the run-pipeline script in seesaw to point at `#!/usr/bin/python2` instead of `#!/usr/bin/python`.
5. `adduser --system --group --shell /bin/bash archiveteam`
6. `screen su -c "cd /home/archiveteam/hyves-grab/; run-pipeline pipeline.py --concurrent 2 --address '127.0.0.1' YOURNICKHERE" archiveteam`

### For FreeBSD:

Honestly, I have no idea. `./get-wget-lua.sh` supposedly doesn't work due to differences in the `tar` that ships with FreeBSD. Another problem is the apparent absence of Lua 5.1 development headers. If you figure this out, please do let us know on IRC (irc.efnet.org #archiveteam).

Troubleshooting
=========================

Broken? These are some of the possible solutions:

### wget-lua was not successfully built

If you get errors about `wget.pod` or something similar, the documentation failed to compile - wget-lua, however, compiled fine. Try this:

    cd get-wget-lua.tmp
    mv src/wget ../wget-lua
    cd ..
    
The `get-wget-lua.tmp` name may be inaccurate. If you have a folder with a similar but different name, use that instead and please let us know on IRC what folder name you had!

Optionally, if you know what you're doing, you may want to use wgetpod.patch.
    
### ImportError: No module named seesaw

If you're sure that you followed the steps to install `seesaw`, permissions on your module directory may be set incorrectly. Try the following:

    chmod o+rX -R /usr/local/lib/python2.7/dist-packages

### Other problems

Have an issue not listed here? Join us on IRC and ask! We can be found at irc.efnet.org #angerthehyve.
