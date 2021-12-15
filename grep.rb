require 'sinatra/base'
require 'yaml'

class Grep < Sinatra::Base
    helpers do
        def find(pattern)
            open('scowl-60.txt').grep(pattern)
        end
    end
    
    get '/grep' do
        pattern = params[:pattern]
        if not pattern or pattern == ''
            redirect to('/')
        end
        content_type 'text/plain'
        matches = find(Regexp.new(pattern.downcase))
        intro = matches.empty? ? "No matches for #{pattern.downcase}" : "Matches for #{pattern.downcase}:"
        intro + "\n" + matches.join
    end

end


