package IO::Writer; 

use Moose::Role; 
use MooseX::Types::Moose qw( Str ); 
use IO::KISS; 
use namespace::autoclean; 
use experimental qw( signatures ); 

has 'output', ( 
    is       => 'ro', 
    isa      => Str,  
); 

has 'o_mode', ( 
    is       => 'ro', 
    isa      => Str, 
    lazy     => 1, 
    init_arg => undef, 
    default  => 'w' 
); 

has 'writer', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_writer', 
    clearer   => '_clear_writer', 
    handles   => { 
        _print        => 'print', 
        _printf       => 'printf', 
        _close_writer => 'close' 
    }
); 

sub _build_writer ( $self ) {
    return IO::KISS->new( 
        file   => $self->output, 
        mode   => $self->o_mode,   
    ) 
} 

1 
