use strict;

package ExternalLinkPluginTests;

use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use Error qw( :try );

sub new {
    my $self = shift()->SUPER::new(@_);
    return $self;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
}

sub loadExtraConfig {
    my $this = shift;

    $this->SUPER::loadExtraConfig();

    $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{MarkerImage} =
      '%PUBURLPATH%/%SYSTEMWEB%/ExternalLinkPlugin/external.gif';
    $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug} = 1;
    $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Module} =
      'Foswiki::Plugins::ExternalLinkPlugin';
    $Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Enabled} = 1;

    $Foswiki::cfg{DefaultUrlHost}='http://foobar.xxx';
    $Foswiki::cfg{ScriptUrlPath}='/foswiki/bin';
    $Foswiki::cfg{ScriptUrlPaths}{view} = '/foswiki/bin/view';
}

sub tear_down {
    my $this = shift;

    # Always do this, and always do it last
    $this->SUPER::tear_down();
}

sub test_renderExternalLinks {
    my ($this) = @_;

    # External link with text
    $this->assert_html_equals(
"<span class='externalLink'><a href='http://google.com/'>Link to Google</a></span>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[http://google.com/][Link to Google]]", 'Sandbox'
            )
        )
    );

    # External ssl link with text
    $this->assert_html_equals(
"<span class='externalLink'><a href='https://google.com/'>SSL to Google</a></span>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[https://google.com/][SSL to Google]]", 'Sandbox'
            )
        )
    );

    # Simple external link, no text  (Does not get external mark)
    $this->assert_html_equals(
        "<a href='http://google.com/'>http://google.com/</a>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[http://google.com/]]", 'Sandbox'
            )
        )
    );

return;
    # External link with text - expand called twice - Item8446
    $this->assert_html_equals(
"<span class='externalLink'><a href='http://google.com/'>Link to Google</a></span>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                Foswiki::Func::expandCommonVariables(
                    " [[http://google.com/][Link to Google]]", 'Sandbox'
                )
            )
        )
    );
}

sub test_renderInternalLinks {
    my ($this) = @_;

    my $url = $Foswiki::cfg{DefaultUrlHost};
    my $viewfile = $Foswiki::cfg{ScriptUrlPath}.'/viewfile';
    my $pubpath  = $Foswiki::cfg{PubUrlPath};
    
    $this->assert_html_equals(
"<a href='$url$pubpath/System/ProjectLogos/favicon.ico'>project logo</a>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[%PUBURL%/System/ProjectLogos/favicon.ico][project logo]]", 'Sandbox'
            )
        )
    );

    $this->assert_html_equals(
"<a href='$url$viewfile/System/ProjectLogos/favicon.ico'>project logo</a>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                "[[%SCRIPTURL{viewfile}%/System/ProjectLogos/favicon.ico][project logo]]", 'Sandbox'
            )
        )
    );


#  Setup for short URLs

    $Foswiki::cfg{ScriptUrlPaths}{view} = '';
    $Foswiki::cfg{ScriptUrlPath} = '/bin';
    $this->createNewFoswikiSession();

return;

    # External link with text  -  Fails - short URLs  Item8563
    $this->assert_html_equals(
"<a href='$url/Main/WebHome'>$url/Main/WebHome</a>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[%SCRIPTURL{view}%/Main/WebHome][main webhome]]", 'Sandbox'
            )
        )
    );

}

sub test_renderI18nLinks {
    my ($this) = @_;

    $Foswiki::cfg{DefaultUrlHost}='http://εμπορικ.xxx';
    $Foswiki::cfg{ScriptUrlPath}='/foswiki/bin';
    $Foswiki::cfg{ScriptUrlPaths}{view} = '/foswiki/bin/view';
    $this->createNewFoswikiSession();

    my $url = $Foswiki::cfg{DefaultUrlHost};
    my $viewfile = $Foswiki::cfg{ScriptUrlPath}.'/viewfile';
    my $pubpath  = $Foswiki::cfg{PubUrlPath};

    # External link with text
    $this->assert_html_equals(
"<span class='externalLink'><a href='http://εμπορικόσήμα.eu/'>Link to greek site</a></span>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[http://εμπορικόσήμα.eu/][Link to greek site]]", 'Sandbox'
            )
        )
    );

    $this->assert_html_equals(
"<a href='$url$pubpath/System/ProjectLogos/favicon.ico'>project logo</a>",
        Foswiki::Func::renderText(
            Foswiki::Func::expandCommonVariables(
                " [[%PUBURL%/System/ProjectLogos/favicon.ico][project logo]]", 'Sandbox'
            )
        )
    );


}

1;
