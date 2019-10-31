==================================================
restructuredText (rst) directives and comments
==================================================

Introduction
=================

An rst directive starts with two periods, and has a keyword
followed by two colons, like this::

    .. MyDirective::

The rst parser is quite flexible and configurable.  Directives
may be added for specialized operations.  Sphinx is a system
that was designed for writing documentation, and, for example,
readthedocs.org uses sphinx.

Display of rst files at github needs to cover two distinct
use-cases:

- The github display is the primary method for displaying
  the file (e.g. for README.rst files)

- The github display is incidental to the primary method
  for displaying the file (e.g. for readthedocs documentation)

Currently, github handles the first case fine, but could
confuse viewers for the second case, because sometimes
content is missing from the github display.

It would seem that one possibility for distinguishing these
two cases is to add a github directive to control the display.

Unfortunately, this would place a burden on every other rst
parser to ignore the github directive (some of them will error
on unknown directives).

Instead, we can assign semantic content to specific comments.

This is a fairly ugly hack, but it has the benefit of not
requiring any document changes that would create problems with
any conformant parser.


The proposed special comment is::

  .. github display [on | off]


If you pass this the "on" value, then all unknown directives
will be displayed as literal code blocks.  If you pass this
the "off" value, then unknown directives will not be displayed.

In addition to controlling the display of literal code blocks,
this also allows you to show comments specifically for github.

For example, somebody could place this at the top of their file::

  .. github display

    This file was designed to be viewed at readthedocs.  Some
    content will not display properly when viewing using the
    github browser.

Tests
==========

By default, unknown directives should be displayed.

.. UnknownDirective::  This is an unknown directive

      it has a lot of stuff underneath it

But we can turn this off, and the next directive should
not be displayed.

.. github display off

.. UnknownDirective::  This is an unknown directive

      it has a lot of stuff underneath it

Or we can turn it back on...

.. github display on

.. UnknownDirective::  This is an unknown directive (3)

      it has a lot of stuff underneath it

Here is a comment that should display at github

.. github display

    YOU SHOULD SEE THIS!

And here is a comment that should not display at github

.. foobar

    YOU SHOULD NOT SEE THIS!

This concludes the tests.
