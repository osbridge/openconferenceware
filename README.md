# OpenConferenceWare

[![Gem Version](https://badge.fury.io/rb/open_conference_ware.png)](http://badge.fury.io/rb/open_conference_ware)
[![Build Status](https://travis-ci.org/osbridge/openconferenceware.png?branch=master)](https://travis-ci.org/osbridge/openconferenceware)
[![Dependency Status](https://gemnasium.com/osbridge/openconferenceware.png)](https://gemnasium.com/osbridge/openconferenceware)
[![Coverage Status](https://coveralls.io/repos/osbridge/openconferenceware/badge.png?branch=master)](https://coveralls.io/r/osbridge/openconferenceware?branch=master)
[![Code Climate](https://codeclimate.com/github/osbridge/openconferenceware.png)](https://codeclimate.com/github/osbridge/openconferenceware)

About
-----

*OpenConferenceWare* is an open source web application for supporting conference-like events. This customizable, general-purpose platform provides proposals, sessions, schedules, tracks, user profiles and more.

By releasing this code under a liberal MIT open source license, we hope to empower other people so they can better organize and participate in more events that support free sharing of information, open society, and involved citizenry.

Installation
------------

OpenConferenceWare is distributed as a [Rails engine](http://guides.rubyonrails.org/engines.html), which means it sits inside a Rails application and adds functionality. While this host application can be built to provide additional parts of your event's website, it will often just serve as a place to configure and customize OpenConferenceWare.

### Requirements

OpenConferenceWare requires Ruby 1.9.3 and a host application built on Rails 4.0.2 or newer.

### Starting from scratch

1. Install the latest version of Rails:

        $ gem install rails -v 4.0.2

2. Create a new application to host OpenConferenceWare for your event:

        $ rails new sloth_party --skip-bundle

3. Add 'open_conference_ware' to the newly-created app's Gemfile

        gem "open_conference_ware", "~> 1.0.0.pre"

4. Run `bundle install`

5. Optionally, configure your app's [database settings](http://guides.rubyonrails.org/configuring.html#configuring-a-database). It's fine to run with the default sqlite configuration, but if you prefer another database, set it up now. OCW is tested with SQLite3, MySQL 5.5, and PostgreSQL 9.3.

6. Install OpenConferenceWare's configuration files and seed data:

        $ bin/rails generate open_conference_ware:install

   If you want OCW to be mounted somewhere other than the root of the application, you can pass a mount point to the generator, like so:

        $ bin/rails generate open_conference_ware:install /ocw

7. Edit `config/initializers/01_open_conference_ware.rb` and `config/secrets.yml` to configure OCW's settings. You'll find comments in these files explaining the available options.

8. All of these newly-generated files, _except config/secrets.yml_, should be added to your version control system. If you're using git, you may want to add `config/secrets.yml` to your `.gitignore`, to ensure it doesn't get shared accidentally.

9. At this point, you should be able to fire up a server and see OpenConferenceWare at [http://localhost:3000](http://localhost:3000)

        $ bin/rails server

### Authentication

OpenConferenceWare uses [OmniAuth](https://github.com/intridea/omniauth/) to allow users to sign in using [a variety of external services](https://github.com/intridea/omniauth/wiki/List-of-Strategies). No authentication method is enabled by default, so you'll need to configure one before deploying OCW.

To do this, just add the gem for the desired provider to your Gemfile, run `bundle install`, and configure it in `config/initializers/02_omniauth.rb`.

For example, to enable sign-in with [Persona](https://login.persona.org/), you would add the [omniauth-persona](https://github.com/pklingem/omniauth-persona) gem to your Gemfile

    gem 'omniauth-persona'

and add the provider to `02_omniauth.rb`

    provider :persona

#### Sign In Forms

Friendly sign-in forms are provided for [OpenID](http://openid.net/) and [Persona](https://login.persona.org/), but it's easy to add your own. After enabling an OmniAuth provider, create a partial view at `app/views/open_conference_ware/authentications/_provider_name.html.erb`, where `provider_name` is the name passed to the provider method in the initializer.

Customization
-------------

### Feature Flags

Many features of OCW can be enabled or disabled to meet your event's needs. These can be toggled by editing flags in `config/initializers/01_open_conference_ware.rb`.

### Views and Styles

Since OpenConferenceWare is an engine, all of its views are packaged inside the gem. To customize things, you can easily override any view by creating one with the same name in your application.

To simplify this process, we've included a generator that will copy views out of the gem for you. Invoking the following command will copy all of OpenConferenceWare's views:

    $ bin/rails generate open_conference_ware:views

If you only need to override a particular set of views, you can pass arguments to the generator to narrow things down. This will copy only the layout file and view related to rooms:

    $ bin/rails generate open_conference_ware:views layouts rooms

You can see a full list of available arguments by running:

    $ bin/rails generate open_conference_ware:views --help

Releases
--------

Both GitHub's [releases page](https://github.com/osbridge/openconferenceware/releases) and `CHANGES.md` provide a summary of significant changes made between releases. If you are running a fork of this software, please carefully read these changes to avoid surprises when you pull the updates into your fork.

### Old Versions

Prior to version 1.0, OpenConferenceWare was distributed as a standalone Rails application. Those releases are  tagged with version numbers, such as `v0.20090416`, which represent the date they were made. The final release to be distributed this was was `v0.20131209`, which is based on Rails 3.2.


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
