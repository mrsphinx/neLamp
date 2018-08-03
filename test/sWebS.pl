#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;

use Protocol::WebSocket::Handshake::Server;
use Protocol::WebSocket::Frame;

my $cv = AE::cv;
my $host = '192.168.4.2';
my $port = 1884;
my %connections;
sub true(){1}
sub false(){0}
tcp_server(
    $host,$port,sub{
        my ($fh)=@_;
        print "connected ..\n";
        my $handle;
        my $hs    = Protocol::WebSocket::Handshake::Server->new;
        my $frame = Protocol::WebSocket::Frame->new;
        $handle = AnyEvent::Handle->new(
            fh=> $fh,
            poll => 'r',
            on_read => sub {
                        my ($self) = @_;
                        my $chunk = $self->{rbuf};
                        $self->{rbuf} = undef;
                        if (!$hs->is_done) {
                                $hs->parse($chunk);
                                if ($hs->is_done) {
                                        $self->push_write($hs->to_string);
                                        return;
                                }
                }
                        $frame->append($chunk);
                        # print "DUMPER:".Dumper($frame);
                        # print"_______________________________________________\n";
                        while (my $message = $frame->next) {
                            # print "result:".Dumper($message);
                            my ($id,$k,$v)= ($message =~ m/^(.+):(.+):(.+)$/);
                            print "COMMAND:".$k."\tValue:".$v."\n";
                            # my @arr=split /^(.+):(.+)$/,$message;
                            # foreach(@arr) {
                            #     print "$_\n";
                            # }
                            if($k eq "REGISTER"){
                                $connections{$handle}->{'hdl'} = $handle;
                                $connections{$handle}->{'hdl'}->push_write($frame->new($id.":".$k.":REGISTERED")->to_bytes);
                            }
                            if($k eq "PING"){
                                $connections{$handle}->{'hdl'}->push_write($frame->new($id.":".$k.":PONG")->to_bytes);
                            }
                            # $self->push_write($frame->new($k.":Ok")->to_bytes)
                            # print "COMMAND:".$command."\tValue:".$value;
                        }
            },
            on_eof => sub {
                        my ($hdl) = @_;
                        delete($connections{$hdl});
                        $hdl->destroy();
            },
            on_error => sub {
                        my ($hdl,$fatal,$message) = @_;
                        print "ON_ERRROR:".$message."\n";
                        delete($connections{$hdl});
                        $hdl->destroy();
            }
        );
        
        return;
});

print "Listening on $host\n";

$cv->wait;

exit 1;