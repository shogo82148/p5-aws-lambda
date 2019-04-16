use Mojolicious::Lite -signatures;

get '/get-link' => sub ($c) {
  $c->render(text => $c->url_for('controller1'));
};

get '/controller1' => sub ($c) {
}, 'controller1';

app->start;
