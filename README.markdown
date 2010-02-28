OpenConferenceWare
==================


About
-----

*OpenConferenceWare* is an open source web application for supporting conference-like events. This customizable, general-purpose platform provides proposals, sessions, schedules, tracks, user profiles and more.

If you only need a simpler system for accepting proposals for Ignite-like events, please consider the stable and well-tested software this code was forked from: OpenProposals, <http://OpenProposals.org/>


Why
---

By releasing this code under a liberal MIT open source license, we hope to empower other people so they can better organize and participate in more events that support free sharing of information, open society, and involved citizenry.


Releases
--------

The stable releases this software are tagged with version numbers, such as `v0.20090416`, which represent the date they were made. There is also a `stable` branch that points to the current stable release. The `CHANGES.txt` file describes a summary of significant changes made between releases. If you are running a fork of this software, please carefully read these changes to avoid surprises when you pull the updates into your fork.


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
- Anyone can create a profile, including a biography, picture and URLs
- Users can login via OpenID
- Users can create proposals until a deadline
- Users can update/delete their own proposals until a deadline
- Users can assign one or many speakers to a proposal
- Users can mark proposals/sessions as favorites
- Administrators can login via OpenID or password
- Administrators can assign/revoke administrator rights of other users
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


Gotchas
-------

Although this software works well and has been used in production on multiple sites for years, there are a number of issues you should be aware of. It remains under heavy development, documentation is scant, tests are incomplete, and the sample theme is broken. These issues are slowly being resolved.


Installation
------------

Installing this application requires familiarity with *UNIX* system administration and *Ruby on Rails* applications.

This application will run best on a UNIX-based dedicated server or virtual machine, and may not run at all on cheap shared hosting because these often restrict the CPU cycles and memory you're allowed to use below what this application requires.

To install the application and its dependencies:

1. Install Git: <http://git-scm.com/>

2. Checkout the OpenConferenceWare source code:

        git clone git://github.com/igal/openconferenceware.git

3. Install Ruby 1.8.6 or 1.8.7 from <http://www.ruby-lang.org/en/downloads/> or Ruby Enterprise Edition from <http://www.rubyenterpriseedition.com/download.html>

4. Install RubyGems 1.3.6 or newer 1.3.x version from <http://rubyforge.org/projects/rubygems>

5. Install Bundler by running the following, likely as `root` or using `sudo`:

        gem install bundler

6. Go into the checkout directory created by `git clone` above:

        cd openconferenceware

7. Install the application's libraries:

        bundle install

8. Run the application's interactive setup and follow its instructions:

        rake setup

9. If you intend to setup a production server, you should consider using Phusion Passenger from <http://www.modrails.com/> or Thin <http://code.macournoyer.com/thin/>

10. If you intend to deploy releases to a production server, consider using Capistrano and read the `config/deploy.rb` file.


Security
--------

This application runs with insecure settings by default to make it easy to get started, and will warn you about this each time you start it. These default settings include publicly-known cryptography keys that will let anyone get administrator privileges on your application. To secure your application, create a `config/secrets.yml` file with your secret settings based on the instructions in the `config/secrets.yml.sample` file.


Customization
-------------

You can customize the application's appearance and behavior by creating a theme, read the `themes/README.txt` file.

*WARNING:* If you are running a fork of this software, you should be able to customize everything by modifying the theme and config files. If you find yourself modifying anything else, you may be doing it wrong and should [get in touch](http://github.com/igal/) to discuss if we can figure out a way to make the platform more generic to support your needs.

*WARNING:* The methods and instance variables used within the theme's application layout are in a state of flux as the software evolves. These will be stabilized for the eventual 1.0 release. In the meantime, please watch the changes made to the `bridgepdx` theme's layout and incorporate them into your own, e.g.:

        git log -p themes/bridgepdx/layouts/application.html.erb


Mailing list
------------

Please join the mailing list if you're interested in using or developing the software: <http://groups.google.com/OpenConferenceWare>


Issue tracker
-------------

Found a bug? I'd like to fix it. Please report it, along with what you tried to do, what you expected, and what actually happened -- or better yet, provide a patch: <http://github.com/igal/openconferenceware/issues>


Contributing
------------

Please contribute fixes and features. You can find issues to work on in the [Issue tracker](http://github.com/igal/openconferenceware/issues). Please fork the source code, make your changes and submit a Github pull request. By submitting a patch, you agree that your software can be released under the same license as this software.


License
-------

This software is provided under an MIT open source license, read the `LICENSE.txt` file for details.


Contributors
------------

This free, open source software was made possible by a group of volunteers that put many hours of hard work into it. See the `CONTRIBUTORS.markdown` file for details.


Copyright
---------

Copyright (c) 2007-2010 Igal Koshevoy, Reid Beels, and others.
