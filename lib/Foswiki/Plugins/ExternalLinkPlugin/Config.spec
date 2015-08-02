# ---+ Extensions
# ---++ ExternalLinkPlugin
# **STRING 50**
# External link image.
$Foswiki::cfg{Plugins}{ExternalLinkPlugin}{MarkerImage} = '%PUBURLPATH%/%SYSTEMWEB%/ExternalLinkPlugin/external.gif';
# **BOOLEAN**
# Enable html link checking for the complete page. Setting this disables the
# commonTagsHandler and enables a completePageHandler.  This may be useful to detect external
# links that are crafted with international characters to appear like internal links.
$Foswiki::cfg{Plugins}{ExternalLinkPlugin}{CheckCompletePage} = 0;
# **BOOLEAN**
# Enable debugging (debug messages will be written to data/debug.txt)
$Foswiki::cfg{Plugins}{ExternalLinkPlugin}{Debug} = 0;
