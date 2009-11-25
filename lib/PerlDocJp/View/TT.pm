package PerlDocJp::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        PerlDocJp->path_to( 'root', 'src' ),
        PerlDocJp->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0
});

=head1 NAME

PerlDocJp::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<PerlDocJp>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

