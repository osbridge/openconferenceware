= Themes

This directory contains themes for this application. Each theme provides
settings for defining the application's behavior and styling to specify
it's appearance.

WARNING: The methods and instance variables used within the theme's
application layout are in a state of flux as the software grows. These
will be stablized for the 1.0 release. In the meantime, please
watch the changes made to the bridgepdx theme's layout and incorporate
them into your own, e.g.:

        git log -p themes/bridgepdx/layouts/application.html.erb

== Initialization

Themes are loaded during the startup process by first looking to see if
the name of a theme was specified in the "THEME" environmental variable,
else in the "config/theme.txt" file, else it falls back to the "default"
theme.

To specify which theme you would like to use, create a new 
config/theme.txt file, containing the name of the folder for the theme 
settings.

== Customizing

See the files in the "themes/default" directory to see the files
necessary to make a theme. See the "themes/default/settings.yml" file
for settings that define how the application should behave.

The "default" theme contains a simple theme that is easiest for you to
derive your own from, while the other themes provide more advanced
examples of what's possible.
