require 'sinatra'
require 'mail'

class Grep < Sinatra::Base
    get '/' do
        "Hello, world"
    end

    get '/grep/:pattern' do
        open('yawl.txt').grep(Regexp.new(params[:pattern])).join
    end

    post '/incoming_mail' do
        mail = Mail.new(params[:message])
        # do something with mail
        puts params[:message]
        'success'
    end

end


