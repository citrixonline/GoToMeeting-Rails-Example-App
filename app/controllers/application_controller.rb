class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def get_api_key
    @api_key = GotomeetingExample::Application.config.go_to_meeting_api_key
  end
  
end
