# OpenConferenceWare

## Recent Developments - Important!

The current master branch is under active development, as part of an ongoing effort to modernize and improve OpenConferenceware. It has currently been upgraded to Rails 3.2.15, and the authentication system has been completely reworked. We are working towards towards several other goals, as seen on the [roadmap](https://github.com/osbridge/openconferenceware/wiki/Roadmap).

Although this branch is in flux, we recommend it as a starting point for any new OCW deployments. The alternative is to use the [legacy](https://github.com/osbridge/openconferenceware/tree/legacy) branch, which is based on Rails 2.1.2 and is much trickier to work with.

While we undertake this work, the Gemfile loads all three of our supported database adapters: `sqlite3`, `mysql2` and `pg`. Feel free to comment out the adapters that you're not using.

### Current Build Status

* [Master](https://github.com/osbridge/openconferenceware/tree/master) (Rails 3.2.15, Ruby 1.9.3 or 2.0): [![Build Status](https://travis-ci.org/osbridge/openconferenceware.png?branch=master)](https://travis-ci.org/osbridge/openconferenceware)
* [Legacy](https://github.com/osbridge/openconferenceware/tree/legacy) (Rails 2.1.2, Ruby 1.8.7): [![Build Status](https://travis-ci.org/osbridge/openconferenceware.png?branch=legacy)](https://travis-ci.org/osbridge/openconferenceware)


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
- Anyone can be informed of new proposals via ATOM feed
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

Although this software works well and has been used in production on multiple sites for years, there are issues you should be aware of. The documentation and ease of setup are not as strong as we want it to be. See our issue tracker on GitHub for known issues, or to report your own.


Installation
------------

Installing this application requires familiarity with *UNIX* system administration and *Ruby on Rails* applications.

This application will run best on a UNIX-based dedicated server or virtual machine, and may not run at all on cheap shared hosting because these often restrict the CPU cycles and memory you're allowed to use below what this application requires.

To install the application and its dependencies:

1. Install Git: <http://git-scm.com/>

2. Checkout the OpenConferenceWare source code:

        git clone git://github.com/osbridge/openconferenceware.git

3. Install Ruby 1.8.6 or 1.8.7 from <http://www.ruby-lang.org/en/downloads/> or Ruby Enterprise Edition from <http://www.rubyenterpriseedition.com/download.html>

4. Install RubyGems 1.3.6 or newer 1.3.x version from <http://rubyforge.org/projects/rubygems>

5. Install Bundler by running the following, likely as `root` or using `sudo`:

        gem install bundler

6. Go into the checkout directory created by `git clone` above:

        cd openconferenceware

7. Install the application's libraries:

        bundle install

8. Optionally configure a custom database, see `config/database.yml` for details.

9. Copy `config/settings.yml.sample` to `config/settings.yml` and `config/secrets.yml.sample` to `config/secrets.yml`. Open these new files up, read through them, and edit as desired to configure OCW.

10. Create your databases using its native tools or by running:

        bundle exec rake db:create:all

11. Run the application's interactive setup and follow its instructions -- WARNING, this will destroy your database's contents:

        bundle exec rake setup

12. Or run the application's interactive setup which pre-populates your database with sample data -- WARNING, this will destroy your database's contents:

        bundle exec rake setup:sample

13. If you intend to setup a production server, you should consider using Phusion Passenger from <http://www.modrails.com/> or Thin <http://code.macournoyer.com/thin/>

14. If you intend to deploy releases to a production server, consider using Capistrano and read the `config/deploy.rb` file.


Security
--------

This application runs with insecure settings by default to make it easy to get started, and will warn you about this each time you start it. These default settings include publicly-known cryptography keys that will let anyone get administrator privileges on your application. To secure your application, create a `config/secrets.yml` file with your secret settings based on the instructions in the `config/secrets.yml.sample` file.


Customization
-------------

Many features of OCW can be enabled or disabled to meet your event's needs. These can be toggled by editing flags in `config/settings.yml`.

*WARNING:* If you are running a fork of this software, you should be able to customize everything by modifying the config files. If you find yourself modifying anything else, you may be doing it wrong and should [get in touch](http://github.com/osbridge/) to discuss if we can figure out a way to make the platform more generic to support your needs.

*WARNING:* The methods and instance variables used within the application layout are in a state of flux as the software evolves. These will be stabilized for the eventual 1.0 release.


Environment variables
-----------------------

You can alter the application's behavior by setting environment variables. For example, to enable query tracing, you can run:

    QUERYTRACE=1 ./script/server

Application behavior is affected by these environment variables:

- `NO_MIGRATION_CHECK=1` disables the check that ensures the database has had all the migrations applied.
- `EXCEPTION_NOTIFIER=1` forces the exception notification system to run, it's only used by default in `production` and `preview` environments.
- `EXCEPTION_EMAILS=1` forces the exception notification system to actually send emails, it's only not used by default in `test` and `development` environments.
- `QUERYTRACE=1` provides logging that shows where each database query is done, handy for identifying unwanted queries.
- `LOCALCSS=1` forces the use of local CSS files when using the `production` or `preview` environments, these default to using the CSS files on the production servers.
- `WEBANALYTICS=1` forces the inclusion of web analytics tracking in the layout, this is enabled by default in the `production` environment.

Usage
-----

Some features of OCW may not be immediately evident as a new user. We will attempt to shed light on them here.

### Selection Committee Voting

OCW allows you to designate members of a content selection committee, who can then view feedback from the public and vote on sessions for inclusion in your conference. In order to enable this:

1. An admin needs to edit users to grant them selection committee privileges.
2. An admin needs to edit the event to accept selector votes.
3. Selection committee members will then see a voting interface on proposal pages and a "selector votes" overview.


Mailing list
------------

Please join the mailing list if you're interested in using or developing the software: <http://groups.google.com/group/openconferenceware>


Issue tracker
-------------

Found a bug? We'd like to fix it. Please report it, along with what you tried to do, what you expected, and what actually happened -- or better yet, provide a patch: <http://github.com/osbridge/openconferenceware/issues>


Contributing
------------

Please contribute fixes and features. You can find issues to work on in the [Issue tracker](http://github.com/osbridge/openconferenceware/issues). Please fork the source code, make your changes and submit a Github pull request. By submitting a patch, you agree that your software can be released under the same license as this software.


License
-------

This software is provided under an MIT open source license, read the `LICENSE.txt` file for details.


Contributors
------------

This free, open source software was made possible by a group of volunteers that put many hours of hard work into it. See the `CONTRIBUTORS.markdown` file for details.


Copyright
---------

Copyright (c) 2007-2013 Igal Koshevoy, Reid Beels, Audrey Eschright, and others.
