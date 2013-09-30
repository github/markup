# -*- mode: rd; coding: utf-8; indent-tabs-mode: nil -*-
=begin
= RDtool 0.6.37
== What is RDtool

RD is Ruby's POD. RDtool is formatter for RD.

== What is Changed

See HISTORY.

== How to Install

 (1)((%su%)) if you install into public directories.
 (2)((%ruby setup.rb%))
 (3)If you want to use , utils/rd-mode.el, install it ((*by hand*)).

== How to use

Simply,
  % rd2 rdfile.rd > outputfile

If you want to indicate format-library, do
  % rd2 -r library rdfile.rd > outputfile

Use ((% rd2 --help %)) for more options.

For options depend on format-library, enter ((%--help%)) after
the indication of format-library. For example,

  % rd2 -r rd/rd2html-lib.rb --help

rd2 load "${HOME}/.rd2rc" when it runs.

== How to write RD?

Please read doc/rd-draft.rd.

== About bug report

If you find a bug in RDtool, please add new
((<"issues at gihtub"|URL:https://github.com/uwabami/rdtool/issues>)),
or E-mail me ((<URL:mailto:uwabami@gfd-dennou.org>)).

== Copyright and License

You can use/re-distribute/change RDtool under Ruby's License or GPL-2+.
see LICNESE.txt and COPYING.txt. This distribution of RDtool include
files that are copyrighted by somebody else, and these files can be
re-distributed under those own license.

These files include the condition of those licenses in themselves. The
license information for every files is as follows.

 Files: */
   * Copyright: 2004 MoonWolf <moonwolf@moonwolf.com>
                2011-2012 Youhei SASAKI <uwabami@gfd-dennou.org>
   * License: Ruby's License or GPL-2+
 Files: lib/rd/rd2man-lib.rb
   * Copyright: 2000  WATANABE Hirofumi
                2012 Youhei SASAKI <uwabami@gfd-dennou.org>
   * License: Ruby's License or GPL-2+
 Files: lib/rd/{head-filter,rd2html-ext-lib,rd2html-ext-opt}.rb
   * Copyright: 2003 Rubikitch
   * License: Ruby's License or GPL-2+
 Files: bin/rdswap
   * Copyright: 1999 C.Hintze
   * License: Ruby's License or GPL-2+
 Files: setup.rb
   * Copyright: 2000-2006 Minero Aoki
   * License: LGPL-2.1
 Files: utils/rd-mode.el
   * Copyright: 1999 Koji Arai, Toshiro Kuwabara.
   * License: GPL-2+

=end
