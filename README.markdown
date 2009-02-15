OpenConferenceWare
==================


About
-----

*OpenConferenceWare* is a web application that provides a suite of tools
for conference organizers. It started out as the [Ignite Portland
proposals site](http://proposals.igniteportland.com/) but has since been
reworked as a general-purpose platform that can be restyled and extended
for running other kinds of events.


Why
---

By releasing this code under a liberal MIT open source license, we hope
to empower other people so they can better organize and participate in
more events that support free sharing of information, open society, and
involved citizenry.


Caution
-------

Do NOT run this software unless you have significant Rails expertise and
are willing to work through some warts. The code is currently under
heavy development; the documentation is scant; the tests are inadequate;
and the sample theme is broken. This is an unfortunate result of having
to get this deployed very quickly. However, the code works, is being
used in production, and these issues will be resolved before long.

In the meantime, if you need a stable, well-tested system for
accepting proposals for simpler Ignite-like events, please instead
consider using the software this was forked from: OpenProposals,
<http://github.com/igal/openconferenceware/tree/master>


Features
--------
- Anyone can list events
- Anyone can list/show proposals for an event
- Anyone can leave private comments about proposals to organizers
- Anyone can get be informed of new proposals via ATOM feed
- Anyone can list/show tracks for an event
- Anyone can list/show session types for an event
- Anyone can subscribe to a feed of proposals for the event
- Users can login via OpenID
- Users can create proposals until a deadline
- Users can update/delete their own proposals until a deadline
- Users can assign one or many speakers to a proposal
- Administrators can login via password or assign rights to OpenID users
- Administrators can update text snippets throughout the site
- Administrators can create/update/delete events
- Administrators can set deadlines for accepting proposals for events
- Administrators can create/update/delete tracks
- Administrators can create/update/delete session types
- Administrators can update/delete any proposal
- Administrators can export proposals and comments to CSV
- Administration can list/show/destroy private comments for proposals
- Administration can subscribe to a feed of private comments for proposals
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

3. Install Ruby 1.8.6: [ftp://ftp.ruby-lang.org/pub/ruby/1.8/](ftp://ftp.ruby-lang.org/pub/ruby/1.8/)

4. Install RubyGems 1.3.x: <http://rubyforge.org/forum/forum.php?forum_id=28071>

5. Install Rails 2.1.x:

        sudo gem install rails --version=2.1.2

6. Install other Ruby libraries:

        sudo gem install facets capistrano capistrano-ext sqlite3-ruby ruby-openid mocha
        sudo gem install mbleigh-acts-as-taggable-on --source http://gems.github.com/
        sudo gem install thoughtbot-paperclip --source http://gems.github.com/

Setup
-----

Run the application's interactive setup program from within the checkout
directory, and follow its instructions:

    rake setup


Security
--------

This application runs with insecure settings by default to make it easy to
get started. These default settings include publicly-known cryptography
keys that can allow attackers to gain admin privileges to your
application. You should create a `config/secrets.yml` file with your
secret settings if you intend to run this application on a server that
can be accessed by untrusted users, read the
[config/secrets.yml.sample](config/secrets.yml.sample) file for details.


Customization
-------------

You can customize the application's appearance and behavior by creating
a theme, read the [themes/README.txt](themes/README.txt) file.


Deployment
----------

If you wish to deploy your application using Capistrano, read the
[config/deploy.rb](config/deploy.rb) file.


Contributing
------------

Bug fixes and features are welcomed. Please fork the source code and submit a
pull request: <http://github.com/igal/openconferenceware/tree/master>

Discussion
----------
Discussion happens on the osbridgepdx-technology list: http://groups.google.com/group/osbridgepdx-technology

An IRC channel is available on irc.freenode.net #pcow

License
-------

This program is provided under an MIT open source license, read the
[LICENSE.txt](LICENSE.txt) file for details.


Copyright
---------

Copyright (c) 2007-2008 Igal Koshevoy, Reid Beels, et al

 vim:tw=72:
