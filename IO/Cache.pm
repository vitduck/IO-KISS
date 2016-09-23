package IO::Cache; 

use Moose::Role; 
use MooseX::Types::Moose qw( HashRef );

use namespace::autoclean; 
use experimental qw( signatures ); 

requires qw( _build_cache ); 

has 'cache', ( 
    is        => 'ro', 
    isa       => HashRef, 
    traits    => [ 'Hash' ], 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_cache', 
    handles   => { 
        read => 'get' 
    }, 
); 

1 
