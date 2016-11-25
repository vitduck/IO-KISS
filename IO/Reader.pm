package IO::Reader; 

use IO::KISS; 

use Moose::Role; 
use MooseX::Types::Moose qw( Str HashRef ); 
use namespace::autoclean; 

use experimental 'signatures'; 

has 'input', ( 
    is       => 'ro', 
    isa      => Str,  
    lazy     => 1, 
    default  => '' 
); 

has 'reader', ( 
    is        => 'ro', 
    isa       => 'IO::KISS', 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_reader', 
    clearer   => '_clear_reader', 
    handles   => { 
        _slurp          => 'slurp', 
        _get_line       => 'get_line', 
        _get_lines      => 'get_lines', 
        _get_paragraph  => 'get_paragraph', 
        _get_paragraphs => 'get_paragraphs', 
        _chomp_reader   => 'chomp', 
        _close_reader   => 'close' 
    }
); 

sub _build_reader ( $self ) {
    return IO::KISS->new( 
        file   => $self->input, 
        mode   => 'r',  
        _chomp => 1
    ) 
} 

1 
