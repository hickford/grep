use Rack::Static, :urls => {"/" => 'index.html'}
require './grep'
run Grep
