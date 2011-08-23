require 'sinatra/base'
require 'mail'
require 'pony'
require 'yaml'

class Grep < Sinatra::Base
    environment = ENV['DATABASE_URL'] ? 'production' : 'development'

    if environment == 'development'
        emailconfig = YAML.load(File.read('config/development.yml'))['email']
    end

    set :email_username, ENV['SENDGRID_USERNAME'] || emailconfig['username']
    set :email_password, ENV['SENDGRID_PASSWORD'] || emailconfig['password']
    set :email_address, 'matt.hickford@gmail.com'
    set :email_service, ENV['EMAIL_SERVICE'] || emailconfig['service']
    set :email_domain, ENV['SENDGRID_DOMAIN'] || 'localhost.localdomain'

    get '/' do
    Pony.mail(
      :from => settings.email_address,
      :to => settings.email_address,
      :subject => "subject",
      :body => "body",
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
    "Hello, world"
    end

    get '/grep/:pattern' do
        open('yawl.txt').grep(Regexp.new(params[:pattern])).join
    end

    post '/incoming_mail' do
         mail = Mail.new(params[:message])
        # do something with mail
        puts params[:message]
        puts params[:message]
        'success'
    end

end


