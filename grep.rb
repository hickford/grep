require 'sinatra/base'
require 'mail'
require 'pony'
require 'yaml'

class Grep < Sinatra::Base
    environment = ENV['DATABASE_URL'] ? 'heroku' : 'development'

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
            open('yawl.txt').grep(pattern).join
        end
        
        def email(to,subject,body)
          Pony.mail(
          :from => settings.email_address,
          :to => to,
          :subject => subject,
          :body => body,
          :port => '587',
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
    
    get '/' do
        File.read('index.html')
    end

    get '/grep/:pattern' do
        pattern = params[:pattern]
        answer = find(Regexp.new(pattern))
        answer
    end

    post '/incoming_mail' do
        correspondent = params[:from]
        subject = params[:subject].chomp.sub(/EOM$/,'').chomp
        body = params[:plain].chomp
        # do something with mail
        pattern = subject
        if answer == ''
        answer = find(Regexp.new(pattern))
            answer = "no matches :("
        end
        email(correspondent,"Re: "+subject,answer+"\n"+"http://grep.herokuapp.com/")
        'success'
    end

end


