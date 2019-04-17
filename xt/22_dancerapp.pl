use Dancer2;

get '/get-link' => sub {
  return uri_for('/controller1');
};

get '/controller1' => sub {

};
 
__PACKAGE__->to_app;
