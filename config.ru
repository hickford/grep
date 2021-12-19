require 'rack/protection'
use Rack::Protection::StrictTransport, :preload => true, :without_session => true
use Rack::Static, :urls => {"/" => 'index.html'}
require './grep'
run Grep
