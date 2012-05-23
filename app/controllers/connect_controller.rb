require "httparty"

class ConnectController < ApplicationController
  
  before_filter :get_api_key
  
  # OAuth is two step process
  # first step is to send user to GoToMeeting to login and approve the application
  # so lets show the user a link
  def new
    @url = url_for(:controller => "connect", :action => "confirm", :only_path => false)
    @connect_url = generate_login_url({"redirect_uri" => @url})
  end
  
  # Oauth is a two step process
  # second step is to get user back from GoToMeeting and exchange code for access key
  def confirm
    # Oauth is a two step process
    # second step is to get user back from GoToMeeting and exchange code for access key
    @response = exchange_response_code_for_access_key(params[:code])
    respond_to do |format|
      if @response['access_token']
        cookies[:access_token] = @response['access_token']
        format.html
      else
        @url = url_for(:controller => "connect", :action => "confirm", :only_path => false)
        @connect_url = generate_login_url({"redirect_uri" => @url})
        format.html { render :action => 'new', :notice => "We could not connect" }
      end
    end
    
  end
  
  private
  
  def generate_login_url(params = {})
    params = params.merge("client_id" => get_api_key)
    query = params.map{|k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v)}"}.join("&")
    "https://api.citrixonline.com/oauth/authorize?" + query
  end
  
  def exchange_response_code_for_access_key(response_code)
    HTTParty.get("https://api.citrixonline.com/oauth/access_token?grant_type=authorization_code&code=#{response_code}&client_id=#{get_api_key}").parsed_response
  end
  
end
