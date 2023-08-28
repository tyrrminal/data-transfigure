use v5.26;

use Object::Pad;
class Data::Transform {
  use Data::Transform::Type::Nested;
  use Data::Transform::Default;
  use Data::Transform::Undef;

  use Data::Transform::Constants;

  use List::Util   qw(max);
  use Module::Util qw(module_path);
  use Scalar::Util qw(blessed);

  field @transformers;

  my sub path_join ($base, $add) {
    return join($PATH_SEPARATOR, ($base, $add));
  }

  my sub _transform ($data, $path, $transformers) {
    my @match;
    for(my $i=0; $i<$transformers->@*; $i++) {
      my $v = $transformers->[$i]->applies_to($data, $path);
      push(@match, [$v, $i, $transformers->[$i]]) if($v != $NO_MATCH);
    }
    return $data unless(@match);

    my $best_match = max(map { $_->[0] } @match);
    @match = sort { $b->[1] - $a->[1] } grep { $_->[0] == $best_match } @match;
    my $transformer = $match[0]->[2];

    my $d = $transformer->isa('Data::Transform::Type::Nested') ? $transformer->transform($data, $path) : $transformer->transform($data);
    $d = __SUB__->($d, $path, $transformers) if(ref($d) && !$transformer->isa('Data::Transform::Type::Nested'));

    return $d;
  }

  ADJUST {
    $self->register(Data::Transform::Undef->new(
      handler => sub($data) { return undef; }
    ));

    $self->register(Data::Transform::Default->new(
      handler => sub($data) { return "$data"; }
    ));

    $self->register(
      Data::Transform::Type::Nested->new(
        type => 'ARRAY', 
        handler => sub ($data, $path) {
          my $i = 0;
          return [map {_transform($_, path_join($path, $i++), [@transformers])} $data->@*];
        }
      )
    );

    $self->register(
      Data::Transform::Type::Nested->new(
        type => 'HASH',
        handler => sub ($data, $path) {
          return {map {$_ => _transform($data->{$_}, path_join($path, $_), [@transformers])} keys($data->%*)};
        }
      )
    );
  }

  method register(@args) {
    foreach my $t (map { ref($_) eq 'ARRAY' ? $_->@* : $_ } @args) {
      require(module_path($t)) unless(ref($t));
      die("Only subclasses of Data::Transform::Base can be registered ($t)") unless($t->isa('Data::Transform::Base'));
      $t = $t->new() unless(ref($t));
      push(@transformers, $t);
    }
  }

  method transform($data) {
    my $d = _transform($data, $PATH_SEPARATOR, [grep { !$_->isa('Data::Transform::PostProcess') } @transformers]);
    foreach (grep { $_->isa('Data::Transform::PostProcess') } @transformers) { $d = $_->transform($d); }
    return $d;
  }

}

1;
