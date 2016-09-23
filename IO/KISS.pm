package IO::KISS; 

use Moose; 
use MooseX::Types::Moose qw( Bool Str Ref GlobRef );  
use Moose::Util::TypeConstraints qw( enum ); 

use namespace::autoclean; 
use feature qw( state switch );  
use experimental qw( signatures smartmatch );  

has 'input', ( 
    is        => 'ro', 
    isa       => Str | Ref, 
    required  => 1, 
); 

has 'mode', ( 
    is        => 'ro', 
    isa       => enum( [ qw( r w a ) ] ),  
    required  => 1, 
); 

has 'chomp', ( 
    is        => 'ro', 
    isa       => Bool, 
    lazy      => 1, 
    default   => 0, 
); 

has 'fh', ( 
    is        => 'ro', 
    isa       => GlobRef, 
    lazy      => 1, 
    init_arg  => undef,
    builder   => '_build_fh', 
); 

override BUILDARGS => sub ( $class, @args ) { 
    return 
        @args == 2  ? { input => $args[0], mode => $args[1] } : 
        super 
}; 

# read 
sub slurp          ( $self ) { return scalar $self->_readline( undef ) }
sub get_line       ( $self ) { return scalar $self->_readline          } 
sub get_lines      ( $self ) { return $self->_readline                 } 
sub get_paragraph  ( $self ) { return scalar $self->_readline ( '' )   }
sub get_paragraphs ( $self ) { return $self->_readline ( '' )          }

# write 
sub print  ( $self, @items )          { print { $self->fh } "@items\n"       } 
sub printf ( $self, $format, @items ) { printf { $self->fh } $format, @items }

# close fh 
sub close ( $self ) { 
    use autodie qw( close ); 
    close $self->fh 
}  

# wrapper of perl's readline 
sub _readline ( $self, $separator = "\n" ) { 
    local $/ = $separator; 
    return 
        wantarray ? 
        do { 
            my @reads = readline $self->fh; 
            chomp @reads if @reads && $self->chomp == 1;  
            @reads 
        } :  
        do { 
            my $read = readline $self->fh; 
            chomp $read if $read && $self->chomp == 1; 
            $read 
        } ; 
} 

# wrapper of perl's open 
sub _build_fh ( $self ) { 
    use autodie qw( open ); 
    my $fh; 

    given ( $self->mode ) { 
        when ( 'r' ) { open $fh, '<' , $self->input } 
        when ( 'w' ) { open $fh, '>' , $self->input } 
        when ( 'a' ) { open $fh, '>>', $self->input }
    }

    return $fh; 
} 

__PACKAGE__->meta->make_immutable;

1 
