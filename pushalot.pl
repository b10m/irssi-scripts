##
## Put me in ~/.irssi/scripts, and then execute the following in irssi:
##
##       /load perl
##       /script load pushalot
##
## Heavily based on https://code.google.com/p/irssi-libnotify/
## We just use the Pushalot API and only send out notifications if we're
## marked as away (suits me, might not suit you). For more on Pushalot,
## see http://pushalot.com/
##
## Don't forget to replace <YOUR_AUTH_TOKEN> with your actual auth_token
## (again, see pushalot.com)

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use HTML::Entities;
use LWP::UserAgent;


$VERSION = "0.0.1";
%IRSSI = (
    authors     => 'Menno Blom',
    contact     => 'menno@b10m.net',
    name        => 'pushalot.pl',
    description => 'Use Pushalot to alert user to hilighted messages',
    license     => 'GNU General Public License',
    url         => 'https://github.com/b10m/irssi-scripts',
);

Irssi::settings_add_str('pushalot', 'pushalot_auth_token', '<YOUR_AUTH_TOKEN>');

sub pushalot {
    my ($server, $summary, $message) = @_;
    print "Debug: $server | $summary | $message\n";
    my $ua ||= LWP::UserAgent->new;
    return if (!$ua);
    return if (Irssi::settings_get_str('pushalot_auth_token') eq '<YOUR_AUTH_TOKEN>');

    $ua->post("https://pushalot.com/api/sendmessage", [
        "AuthorizationToken" => Irssi::settings_get_str('pushalot_auth_token'),
        "Body" => "$summary: $message",
    ]) if $server->{usermode_away};
}

sub print_text_pushalot {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};

    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
    pushalot($server, $dest->{target}, $stripped);
}

sub message_private_pushalot {
    my ($server, $msg, $nick, $address) = @_;

    return if (!$server);
    pushalot($server, "Private message from ".$nick, $msg);
}

sub dcc_request_pushalot {
    my ($dcc, $sendaddr) = @_;
    my $server = $dcc->{server};

    return if (!$server || !$dcc);
    pushalot($server, "DCC ".$dcc->{type}." request", $dcc->{nick});
}

Irssi::signal_add('print text', 'print_text_pushalot');
Irssi::signal_add('message private', 'message_private_pushalot');
Irssi::signal_add('dcc request', 'dcc_request_pushalot');

print "Use /set pushalot_auth_token = YOUR_TOKEN_HERE to activate the pushalot script\n"
   if Irssi::settings_get_str('pushalot_auth_token') eq '<YOUR_AUTH_TOKEN>';
