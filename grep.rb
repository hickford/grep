require 'sinatra/base'
require 'mail'
require 'pony'
require 'yaml'

class Grep < Sinatra::Base
    if not ENV['SENDGRID_USERNAME']
        emailconfig = YAML.load(File.read('config/development.yml'))['email']
    end

    set :email_username, ENV['SENDGRID_USERNAME'] || emailconfig['username']
    set :email_password, ENV['SENDGRID_PASSWORD'] || emailconfig['password']
    set :email_address, ENV['CLOUDMAILIN_FORWARD_ADDRESS'] || emailconfig['address']
    set :email_service, ENV['EMAIL_SERVICE'] || emailconfig['service']
    set :email_domain, ENV['SENDGRID_DOMAIN'] || 'localhost.localdomain'
      
    helpers do
        def find(pattern)
            open('yawl.txt').grep(pattern)
        end
        
        def email(to,subject,body)
          Pony.mail(
          :from => settings.email_address,
          :to => to,
          :subject => subject,
          :body => body,
          #:port => '587',
          :via => :smtp,
          :via_options => { 
            :port                 => '587', 
            :address              => 'smtp.' + settings.email_service, 
            :enable_starttls_auto => true, 
            :user_name            => settings.email_username, 
            :password             => settings.email_password, 
            :authentication       => :plain, 
            :domain               => settings.email_domain
          })
        end
    end
    
    get '/grep' do
        pattern = params[:pattern]
        if not pattern or pattern == ''
            redirect to('/')
        end
        content_type 'text/plain'
        cache_control :public
        answer = find(Regexp.new(pattern.downcase)).join
    end

    post '/incoming_mail' do
        correspondent = params[:from]
        subject = params[:subject].chomp.sub(/\s\W?EOM\W?$/i,'').chomp
        body = params[:plain].chomp
        # do something with mail
        pattern = subject
        matches = find(Regexp.new(pattern.downcase))
        answer = matches ? matches.join : "no matches :("
        email(correspondent,"Re: #{subject}","#{answer}\nhttp://grep.herokuapp.com/")
        content_type 'text/plain'
        "Emailed #{matches.length} matches for #{pattern} to #{correspondent}"
    end

end


