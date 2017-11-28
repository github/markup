#!/bin/bash

./lib/github/commands/pod2html <( cat - <<EOF
=pod

=head1 NAME

Test

=cut

# -*- mode: perl; -*-
EOF
) | grep -q '<h1 id="NAME">' || { echo "not ok 1"; exit 1; } && { echo "ok 1"; }

./lib/github/commands/pod2html <( cat - <<EOF
#!/usr/bin/perl
# -*- mode: perl; -*-

=pod

=head1 NAME

Test

=cut
EOF
) | grep -q '<h1 id="NAME">' || { echo "not ok 2"; exit 1; } && { echo "ok 2"; }
