# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2005 Aurélio A Heckert <aurium@gmail.com>,
#                    Nelson Ferraz <nferraz@gmail.com>,
#                    Antonio Terceiro <asaterceiro@inf.ufrgs.br>
# Copyright (C) 2009 Arthur Clemens <arthur@visiblearea.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::ExternalLinkPlugin;

our $VERSION           = '1.30';
our $RELEASE           = '1.30';
our $NO_PREFS_IN_TOPIC = 1;
our $SHORTDESCRIPTION  = 'Adds a visual indicator to outgoing links';
our $pluginName = 'ExternalLinkPlugin';    # Name of this Plugin

my $protocolsPattern;
my $addedToHead;

sub initPlugin {
    my ( $topic, $web, $user, $installWeb ) = @_;

    # check for Plugins.pm versions
    if ( $Foswiki::Plugins::VERSION < 1.021 ) {
        Foswiki::Func::writeWarning(
            "Version mismatch between $pluginName and Plugins.pm");
        return 0;
    }

    $protocolsPattern =
      Foswiki::Func::getRegularExpression('linkProtocolPattern');
    $addedToHead = 0;
    addStyleToHead();

    Foswiki::Func::writeDebug(
        "- Foswiki::Plugins::${pluginName}::initPlugin( $web.$topic ) is OK")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};
    return 1;
}

sub addStyleToHead {

    return if $addedToHead;

    Foswiki::Func::writeDebug("- ${pluginName}::addStyleToHead")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    # Untaint is required if use locale is on
    Foswiki::Func::loadTemplate(
        Foswiki::Sandbox::untaintUnchecked( lc($pluginName) ) );
    my $header = Foswiki::Func::expandTemplate('externallink:header');

    $header =~
      s/%markerimage%/$Foswiki::cfg{Plugins}{ExternalLinkPlugin}{MarkerImage}/g;
    Foswiki::Func::addToHEAD( $pluginName, $header );

    $addedToHead = 1;
}

sub commonTagsHandler {
### my ( $text, $topic, $web ) = @_;   # do not uncomment, use $_[0], $_[1]... instead

    Foswiki::Func::writeDebug(
        "- ${pluginName}::commonTagsHandler( $_[2].$_[1] )")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    # This is the place to define customized tags and variables
    # Called by Foswiki::handleCommonTags, after %INCLUDE:"..."%

    # do custom extension rule, like for example:
    $_[0] =~
s!(\[\[($protocolsPattern://[^]]+?)\]\[[^]]+?\]\]([&]nbsp;)?)! handleExternalLink($1, $2) !ge;
}

sub handleExternalLink {
    my ( $wholeLink, $url ) = @_;

    my $scriptUrl = "$Foswiki::cfg{DefaultUrlHost}$Foswiki::cfg{ScriptUrlPath}";
    my $pubUrl    = "$Foswiki::cfg{DefaultUrlHost}$Foswiki::cfg{PubUrlPath}";

    Foswiki::Func::writeDebug(
        "Comparing SCRIPTURL ($scriptUrl)\n pubUrl ($pubUrl)\n with ($wholeLink)")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    if (   ( $url =~ /^$scriptUrl/ )
        || ( $url =~ /^$pubUrl/ )
        || ( $url =~ /^$Foswiki::cfg{DefaultUrlHost}\// )
        || ( $wholeLink =~ /[&]nbsp;$/ ) )
    {
        return $wholeLink;
    }
    else {
        return "<span class='externalLink'>$wholeLink</span>";
    }

}

1;

