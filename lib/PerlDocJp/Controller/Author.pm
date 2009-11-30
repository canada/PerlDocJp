package PerlDocJp::Controller::Author;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use YAML::Syck;
use Encode;
use Encode::Guess qw/eucjp utf8 shiftjis 7bit-jis/;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

PerlDocJp::Controller::Root - Root Controller for PerlDocJp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut
sub author : Local {
    my ( $self, $c) = @_;

    my $count = 0;
    foreach('a' .. 'z'){
        $c->stash->{items}[$count]{uc} = uc($_);
        $c->stash->{items}[$count]{lc} = lc($_);
        $count++;
    }
}

sub author_detail :LocalRegex('^~([-a-z*]+)/?$') { # author xxx's page
    my ( $self, $c) = @_;
    my $uid   = $c->req->snippets->[0];
    my $model = $c->model('Author');
    my $auth  = $model->get($uid);
    $c->stash->{items}{author} = $auth;
    $c->stash->{items}{author}{author_uid_lc} = lc($auth->{author_uid});
    $c->stash->{items}{dist}   = $model->get_dist($auth->{author_id});
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
