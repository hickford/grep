require 'sinatra/base'

class Grep < Sinatra::Base
    configure do
        set :words, File.readlines('scowl-60.txt')
    end

    helpers do
        def find(pattern)
            settings.words.grep(pattern)
        end
    end
    
    get '/grep' do
        pattern = params[:pattern].strip
        if not pattern or pattern == ''
            redirect to('/')
        end
        content_type 'text/plain'
        matches = find(Regexp.new(pattern.downcase))
        intro = matches.empty? ? "No matches for #{pattern.downcase}" : "Matches for #{pattern.downcase}:"
        intro + "\n" + matches.join
    end

end


