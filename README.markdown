OpenConferenceWare
==================


About
-----

*OpenConferenceWare* is an open source web application for events and
conferences. This customizable, general-purpose platform provides
proposals, sessions, schedules, tracks and more.


Why
---

By releasing this code under a liberal MIT open source license, we hope
to empower other people so they can better organize and participate in
more events that support free sharing of information, open society, and
involved citizenry.


Releases
--------

The stable releases this software are tagged with version numbers,
such as "v0.20090416", that represent the date they were made.
There is also a "stable" branch that points to the current stable
release. The [CHANGES.txt](CHANGES.txt) file describes a summary of
significant changes made between stable releases.

The code works well and is being used in production on multiple sites.
However, it is under heavy development, documentation is scant, tests
are incomplete, and the sample theme is broken. These issues are being
resolved, but the main focus is currently adding features to support the
needs of Open Source Bridge and Linux Plumbers Conference. It is
strongly recommended that you have access to an experienced Ruby on
Rails developer if you intend to use this software.

If you need a simpler system for accepting proposals for Ignite-like
events, please consider the stable and well-tested software this code
was forked from: OpenProposals,
<http://OpenProposals.org/>


Features
--------
- Anyone can list events
- Anyone can list/show sessions for an event
- Anyone can list/show proposals for an event
- Anyone can leave private comments about proposals to organizers
- Anyone can get be informed of new proposals via ATOM feed
- Anyone can list/show tracks for an event
- Anyone can list/show session types for an event
- Anyone can subscribe to a feed of proposals for the event
- Anyone can list/show rooms for an event
- Users can login via OpenID
- Users can create proposals until a deadline
- Users can update/delete their own proposals until a deadline
- Users can assign one or many speakers to a proposal
- Administrators can login via password or assign rights to OpenID users
- Administrators can update text snippets throughout the site
- Administrators can create/update/delete events
- Administrators can set deadlines for accepting proposals for events
- Administrators can export proposals and comments to CSV
- Administrators can update/delete any proposal
- Administrators can set status of any proposal (e.g., accept, reject)
- Administrators can create/update/delete tracks
- Administrators can create/update/delete session types
- Administrators can create/update/delete rooms
- Administrators can list/show/destroy private comments for proposals
- Administrators can subscribe to a feed of private comments for proposals
- Developers can customize the site's appearance and behavior
- ...and many more features are planned for the future!


Expertise
---------

Installing the app requires familiarity with *UNIX* system administration
and *Ruby on Rails*. This application will run best on a UNIX-based
dedicated server or virtual machine, and may not run at all on cheap
shared hosting because these often limit memory usage below the minimum
threshold for this application. You will need to install software that
this application depends on either as root or compile it yourself. You
will need to setup an application server to run the application, e.g.,
`mod_passenger`. If you do not have these skills, contact your local Ruby
or Linux user group and you will likely find someone that can help.


Dependencies
------------

1. Install Git: <http://git.or.cz/>

2. Checkout the OpenConferenceWare source code:

        git clone git://github.com/igal/openconferenceware.git

3. Install Ruby 1.8.6 or 1.8.7 from [ftp://ftp.ruby-lang.org/pub/ruby/1.8/](ftp://ftp.ruby-lang.org/pub/ruby/1.8/) or Ruby Enterprise Edition from [http://www.rubyenterpriseedition.com/download.html](http://www.rubyenterpriseedition.com/download.html)

4. Install RubyGems 1.3.x: <http://rubyforge.org/forum/forum.php?forum_id=28071>
5. Install Rails 2.1.x:

        sudo gem install rails --version=2.1.2

6. Install other Ruby libraries from within the checkout directory:

        sudo rake gems:install

Setup
-----

Run the application's interactive setup program from within the checkout
directory, and follow its instructions:

        rake setup


Security
--------

This application runs with insecure settings by default to make it easy
to get started. These default settings include publicly-known
cryptography keys that can allow attackers to gain admin privileges to
your application. You should create a `config/secrets.yml` file with
your secret settings if you intend to run this application on a server
that can be accessed by untrusted users, read the
[config/secrets.yml.sample](config/secrets.yml.sample) file for details.


Customization
-------------

You can customize the application's appearance and behavior by creating
a theme, read the [themes/README.txt](themes/README.txt) file.

WARNING: The methods and instance variables used within the theme's
application layout are in a state of flux as the software grows. These
will be stablized for the 1.0 release. In the meantime, please
watch the changes made to the bridgepdx theme's layout and incorporate
them into your own, e.g.:

        git log -p themes/bridgepdx/layouts/application.html.erb


Deployment
----------

If you wish to deploy your application using Capistrano, read the
[config/deploy.rb](config/deploy.rb) file.


Mailing list
------------

Please join the mailing list if you're interested in using or developing
the software: <http://groups.google.com/OpenConferenceWare>


Issue tracker
-------------

Found a bug? I'd like to fix it. Please report it, along with what you
tried to do, what you expected, and what actually happened:
<http://github.com/igal/openconferenceware/issues>


Contributing
------------

Contributions of fixes and features are welcomed. Please fork the source
code and submit a pull request:
<http://github.com/igal/openconferenceware/tree/master>


License
-------

This program is provided under an MIT open source license, read the
[LICENSE.txt](LICENSE.txt) file for details.


Contributors
------------

This free, open source software was made possible by a group of
volunteers that put many hours of hard work into it. See the
[CONTRIBUTORS.markdown](CONTRIBUTORS.markdown) file for details.


Copyright
---------

Copyright (c) 2007-2009 Igal Koshevoy, Reid Beels, et al

 vim:tw=72:
