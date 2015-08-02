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

use strict;
use warnings;

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


    # Choose one.  Either the commonTagsHandler or the completePageHandler is needed
    # not both.
    if ( $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{CheckCompletePage} ) {
        undef *commonTagsHandler;
    }
    else {
        undef *completePageHandler;
    }

    $protocolsPattern =
      Foswiki::Func::getRegularExpression('linkProtocolPattern');
    $addedToHead = 0;
    addStyleToHead();

    Foswiki::Func::writeDebug(
        "- Foswiki::Plugins::ExternalLinkPlugin::initPlugin( $web.$topic ) is OK")
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

    if ( $Foswiki::Plugins::VERSION >= 2.1 ) {
        # Foswiki 1.1.0 and later. 
        Foswiki::Func::addToZone( 'head', 'EXTERNALLINKPLUGIN_CSS', $header );
    }
    else {
        # compatibility with Foswiki 1.0
        Foswiki::Func::addToHEAD( $pluginName, $header );
    }


    $addedToHead = 1;
}

sub commonTagsHandler {
### my ( $text, $topic, $web ) = @_;   # do not uncomment, use $_[0], $_[1]... instead

    Foswiki::Func::writeDebug(
        "- ${pluginName}::commonTagsHandler( $_[2].$_[1] )")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    # This is the place to define customized tags and variables
    # Called by Foswiki::handleCommonTags, after %INCLUDE:"..."%

    #print STDERR "===COMMONTAGS CALLED===\n($_[0])\n\n";

    #Scan for [[protocol://links][With text]] and [[protocol://links]] without text
    # - zero length look behind negative assertion - not already part of an external link span
    $_[0] =~
s#(?<!<span class='externalLink'>)(\[\[($protocolsPattern://[^]]+?)\](?:\[[^]]+?\])?\]([&]nbsp;)?)# handleExternalLink($1, $2) #ge;

}

# The completePageHandler is done this way so that the unit tests
# can run the handler directly. The init routine will undef this handler.
# but the private method will remain available.
sub completePageHandler {
    goto &_completePageHandler;
}

sub _completePageHandler {
### my ( $html, $headers ) = @_;   # do not uncomment, use $_[0], $_[1]... instead

    Foswiki::Func::writeDebug(
        "- ${pluginName}::completePageHandler ")
      if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    #Scan for raw html links: <a..></a>
    # - zero length look behind negative assertion - not already part of an external link span
    $_[0] =~ s#(?<!<span class='externalLink'>)(<a .*?href=(["'])($protocolsPattern://.*?)\2.*?>.*?</a>)#  handleExternalLink($1, $3) #ge;
}

sub handleExternalLink {
    my ( $wholeLink, $url ) = @_;

    my $scriptUrl = "$Foswiki::cfg{DefaultUrlHost}$Foswiki::cfg{ScriptUrlPath}";
    my $pubUrl    = "$Foswiki::cfg{DefaultUrlHost}$Foswiki::cfg{PubUrlPath}";

    #Foswiki::Func::writeDebug(
    #  "Comparing SCRIPTURL ($scriptUrl)\n pubUrl ($pubUrl)\n  defaultUrl ($Foswiki::cfg{DefaultUrlHost})\nwith $url ($wholeLink)" )
    #   if $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug};

    if (   ( $url =~ /^$scriptUrl/ )
        || ( $url =~ /^$pubUrl/ )
        || ( $url =~ /^$Foswiki::cfg{DefaultUrlHost}(?:\/|$)/ )
        || ( $wholeLink =~ /[&]nbsp;$/ ) )
    {
        return $wholeLink;
    }
    else {
        return "<span class='externalLink'>$wholeLink</span>";
    }

}

1;

