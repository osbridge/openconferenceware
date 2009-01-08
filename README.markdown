OpenProposals
=============


About
-----

*OpenProposals* is a web application for collecting presentation
proposals for conferences and events. It started out as the [Ignite
Portland proposals site](http://proposals.igniteportland.com/) but has
since been reworked as a general-purpose platform that can be restyled
and extended for collecting proposals for other events.


Why
---

By releasing this code under a liberal MIT open source license, we hope
to empower other people so they can better organize and participate in
more events that support free sharing of information, open society, and
involved citizenry.


Features
--------
- Anyone can list events
- Anyone can list/show proposals for an event
- Anyone can leave private comments about proposals to organizers
- Anyone can get be informed of new proposals via ATOM feed
- Users can login via OpenID
- Users can create proposals until a deadline
- Users can update/delete their own proposals until a deadline
- Administrators can login via password
- Administrators can update text snippets throughout the site
- Administrators can create/update/delete/list/show events
- Administrators can set deadlines for accepting proposals for events
- Administrators can update/delete any proposal
- Administrators can export proposals to CSV
- Developers can customize the site's appearance and behavior


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

2. Checkout the OpenProposals source code:

        git clone git://github.com/igal/openproposals.git

3. Install Ruby 1.8.6: [ftp://ftp.ruby-lang.org/pub/ruby/1.8/](ftp://ftp.ruby-lang.org/pub/ruby/1.8/)

4. Install RubyGems 1.3.x: <http://rubyforge.org/forum/forum.php?forum_id=28071>

5. Install Rails 2.1.x:

        sudo gem install rails --version=2.1.2

6. Install other Ruby libraries:

        sudo gem install facets capistrano capistrano-ext sqlite3-ruby


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
pull request: <http://github.com/igal/openproposals/tree/master>


License
-------

This program is provided under an MIT open source license, read the
[LICENSE.txt](LICENSE.txt) file for details.


Copyright
---------

Copyright (c) 2007-2008 Igal Koshevoy

 vim:tw=72:
