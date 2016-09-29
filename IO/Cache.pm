package IO::Cache; 

use Moose::Role; 
use MooseX::Types::Moose qw( HashRef );
use namespace::autoclean; 

use experimental qw( signatures ); 

requires qw( _build_cache ); 

has 'cache', ( 
    is        => 'ro', 
    isa       => HashRef, 
    traits    => [ qw( Hash ) ], 
    lazy      => 1, 
    init_arg  => undef, 
    builder   => '_build_cache',  
    clearer   => '_clear_cache'
); 

1 
