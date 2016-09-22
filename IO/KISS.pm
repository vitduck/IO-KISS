package IO::KISS; 

use Moose; 
use MooseX::Types::Moose qw( Str Ref GlobRef );  
use Moose::Util::TypeConstraints qw( enum ); 
use namespace::autoclean; 
use feature qw( state switch );  
use experimental qw( signatures smartmatch );  

has 'stream', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    required  => 1, 
); 

has 'mode', ( 
    is        => 'ro', 
    isa       => enum( [ qw( r w a ) ] ),  
    required  => 1, 
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef,
    builder   => '_build_fh', 
); 

override BUILDARGS => sub ( $class, @args ) { 
    return (
        @args == 2  ? 
        { stream => $args[0], mode => $args[1] } : 
        super 
    )
}; 

# read
sub slurp ( $self ) { 
    local $/ = undef; 
    return readline $self->fh 
}

sub get_line ( $self ) { 
    return scalar( readline $self->fh ) 
} 

sub get_lines ( $self ) { 
    return ( readline $self->fh ) 
} 

sub get_paragraph ( $self ) { 
    local $/ = ''; 
    return sclar( readline $self->fh ) 
} 

sub get_paragraphs ( $self ) { 
    local $/ = ''; 
    return ( readline $self->fh ) 
} 

# write
sub print ( $self, @items ) { 
    print { $self->fh } "@items\n"; 
} 

sub printf ( $self, $format, @items ) { 
    printf { $self->fh } $format, @items; 
}

# close filehandler
sub close ( $self ) { 
    use autodie qw( close );  
    close $self->fh; 
} 

sub _build_fh ( $self ) { 
    use autodie qw( open );  
    my $fh; 

    given ( $self->mode ) { 
        when ( 'r' ) { open $fh, '<' , $self->stream } 
        when ( 'w' ) { open $fh, '>' , $self->stream } 
        when ( 'a' ) { open $fh, '>>', $self->stream }
    }

    return $fh; 
} 

__PACKAGE__->meta->make_immutable;

1 
