use Rack::Static, :urls => {"/" => 'index.html'}
require './grep'
require 'rack/protection'
use Rack::Protection::StrictTransport
run Grep
