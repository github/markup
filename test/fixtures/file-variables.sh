#!/bin/bash

t=1
./lib/github/commands/pod2html <( cat - <<EOF
=pod

=head1 NAME

Test

=cut

# -*- mode: perl; -*-
EOF
) | grep -q '<h1 id="NAME">' || { echo "not ok $t"; exit 1; } && { echo "ok $t"; }
let t=($t + 1)

./lib/github/commands/pod2html <( cat - <<EOF
#!/usr/bin/perl
# -*- mode: perl; -*-

=pod

=head1 NAME

Test

=cut
EOF
) | grep -q '<h1 id="NAME">' || { echo "not ok $t"; exit 1; } && { echo "ok $t"; }
let t=($t + 1)
