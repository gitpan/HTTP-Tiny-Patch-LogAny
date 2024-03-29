package HTTP::Tiny::Patch::LogAny;

use 5.010001;
use strict;
no warnings;

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

our $VERSION = '0.01'; # VERSION

our %config;

my $p_request = sub {
    require Log::Any;
    my $log = Log::Any->get_logger;

    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $proto = ref($_[0]) =~ /^LWP::Protocol::(\w+)::/ ? $1 : "?";

    if ($config{-log_request} && $log->is_trace) {
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
            if $Log::{"Log4perl::"};

        my ($self, $method, $url, $args) = @_;
        my $hh = $args->{headers} // {};
        $log->tracef("HTTP::Tiny request (not raw):\n%s %s\n%s\n",
                     $method, $url,
                     join("", map {"$_: $hh->{$_}\n"} sort keys %$hh));
    }

    my $res = $orig->(@_);

    if ($config{-log_response} && $log->is_trace) {
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
            if $Log::{"Log4perl::"};

        my $hh = $res->{headers} // {};
        $log->tracef("HTTP::Tiny response (not raw):\n%s %s %s\n%s\n",
                     $res->{status}, $res->{reason}, $res->{protocol},
                     join("", map {"$_: $hh->{$_}\n"} sort keys %$hh));
    }

    if ($config{-log_response_content} && $log->is_trace) {
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
            if $Log::{"Log4perl::"};

        $log->tracef("HTTP::Tiny response content (%d bytes): %s",
                     length($res->{content} // ""), $res->{content});
    }

    $res;
};

sub patch_data {
    return {
        v => 3,
        config => {
            -log_request => {
                schema  => 'bool*',
                default => 1,
            },
            -log_response => {
                schema  => 'bool*',
                default => 1,
            },
            -log_response_content => {
                schema  => 'bool*',
                default => 0,
            },
        },
        patches => [
            {
                action      => 'wrap',
                mod_version => qr/^0\.*/,
                sub_name    => 'request',
                code        => $p_request,
            },
        ],
    };
}

1;
# ABSTRACT: Log HTTP::Tiny with Log::Any


__END__
=pod

=head1 NAME

HTTP::Tiny::Patch::LogAny - Log HTTP::Tiny with Log::Any

=head1 VERSION

version 0.01

=head1 SYNOPSIS

 use HTTP::Tiny::Patch::LogAny (
     -log_request          => 1, # default 1
     -log_response         => 1, # default 1
     -log_response_content => 1, # default 0
 );

=head1 DESCRIPTION

This module patches L<HTTP::Tiny> to log various stuffs with L<Log::Any>.
Currently this is what gets logged:

=over

=item * HTTP request

Currently *NOT* the raw/on-the-wire request.

=item * HTTP response

Currently *NOT* the raw/on-the-wire response.

=back

=for Pod::Coverage ^(patch_data)$

=head1 CONFIGURATION

=head2 -log_request => BOOL

=head2 -log_response => BOOL

Content will not be logged though, enable C<-log_response_content> for that.

=head2 -log_response_content => BOOL

=head1 FAQ

=head1 SEE ALSO

L<Log::Any::For::LWP>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

