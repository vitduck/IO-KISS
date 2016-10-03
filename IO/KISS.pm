package IO::KISS; 

use Moose; 
use MooseX::Types::Moose qw( Bool Str Ref GlobRef );  
use Moose::Util::TypeConstraints qw( enum ); 
use namespace::autoclean; 

use feature qw( state switch );  
use experimental qw( signatures smartmatch );  

has 'file', ( 
    is        => 'ro', 
    isa       => Str, 
    predicate => 'has_file' 
); 

has 'string', ( 
    is        => 'ro', 
    isa       => Ref, 
    predicate => 'has_string'
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
    builder   => '_build_fh'
); 

has '_chomp', ( 
    is        => 'rw', 
    isa       => Bool, 
    traits    => [ 'Bool' ], 
    lazy      => 1, 
    default   => 0, 
    handles   => { 
        chomp => 'set'
    }
);

# simplified costructor
override BUILDARGS => sub ( $class, @args ) { 
    return 
        @args == 2 
        ? do { 
            ref( $args[0] )  
            ? return { string => $args[0], mode => $args[1] }  
            : return { file   => $args[0], mode => $args[1] } 
        } 
        : super 
}; 

# read 
sub slurp          ( $self ) { return scalar $self->_readline( undef ) } 
sub get_line       ( $self ) { return scalar $self->_readline          }  
sub get_lines      ( $self ) { return        $self->_readline          }
sub get_paragraph  ( $self ) { return scalar $self->_readline( '' )    }
sub get_paragraphs ( $self ) { return        $self->_readline( '' )    }

# write 
sub print  ( $self, @items )          { print { $self->fh } "@items\n"       } 
sub printf ( $self, $format, @items ) { printf { $self->fh } $format, @items } 

# close fh 
sub close ( $self ) { 
    use autodie qw( close ); 
    close $self->fh 
}  

sub _build_fh ( $self ) { 
    return $self->_open_fh( $self->file )   if $self->has_file;  
    return $self->_open_fh( $self->string ) if $self->has_string; 
} 

# wrapper of perl's open 
sub _open_fh ( $self, $io_stream ) { 
    use autodie qw( open ); 
    my $fh; 

    given ( $self->mode ) { 
        when ( 'r' ) { open $fh, '<' , $io_stream } 
        when ( 'w' ) { open $fh, '>' , $io_stream } 
        when ( 'a' ) { open $fh, '>>', $io_stream }
    }

    return $fh; 
} 

# wrapper of perl's readline
sub _readline ( $self, $separator = "\n" ) { 
    return 
        wantarray 
        ? do { 
            my @reads = do { 
                local $/ = $separator; 
                readline $self->fh 
            }; 

            chomp @reads if @reads && $self->_chomp;  
            @reads 
        } 
        : do { 
            my $read = do { 
                local $/ = $separator; 
                readline $self->fh 
            }; 

            chomp $read if $read && $self->_chomp; 
            $read  
        }  
} 

__PACKAGE__->meta->make_immutable;

1 
