require 'rubygems'
require "go_to_meeting"

class MeetingsController < ApplicationController
  
  before_filter :require_access_token
  before_filter :generate_meeting_client
  
  # show meetings
  def index 
    past_meetings
    scheduled_meetings
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @meeting = @go_to_meeting_client.get_meeting(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def new
    @meeting = {}
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @meeting = {}
    # convert start/end times to compatible format
    @meeting['subject'] = params[:subject] 
    @meeting['startTime'] = params[:startTime].utc.iso8601
    @meeting['endTime'] = params[:endTime].utc.iso8601
    
  respond_to do |format|
      if @result = @go_to_meeting_client.create_meeting(@meeting)
        format.html { redirect_to :action => 'show', :id => @result['meetingid'] , notice: 'Meeting was successfully created.' }
      else
        flash[:notice] = "Could not save meeting"
        format.html { render action: "new" }
      end
    end
  end
  
  def edit
    @meeting = @go_to_meeting_client.get_meeting(params[:id])
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  def update
    @meeting = @go_to_meeting_client.get_meeting(params[:id])
    
    params[:startTime] = params[:startTime].utc.iso8601
    params[:endTime] = params[:endTime].utc.iso8601
    
    respond_to do |format|
      if @go_to_meeting_client.update_meeting(params[:id], params)
        format.html { redirect_to :action => "show", :id => params[:id], notice: 'Meeting was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
      end
    end
  end
  
  def destroy
    @go_to_meeting_client.delete_meeting(params[:id])
    respond_to do |format|
      if @go_to_meeting_client.delete_meeting(params[:id])
        format.html { redirect_to meetings_url, 'Meeting was deleted' }
      else
        format.html { redirect_to :action => 'show', :id => params[:id]}
      end
    end
  end
  
  private
  
  def scheduled_meetings
    @scheduled_meetings = @go_to_meeting_client.get_meetings({"scheduled" => "true"})
  end
  
  def past_meetings
    @past_meetings = @go_to_meeting_client.get_meetings({
      "history" => "true", 
      "endDate" => (Time.now - 15).utc.iso8601, 
      "startDate" => (Time.now - (60 * 60 * 24 * 90)).utc.iso8601 })
  end
  
  def generate_meeting_client
    @go_to_meeting_client = GoToMeeting::Client.new(cookies['access_token'].to_s)
  end
  
  def require_access_token
    redirect_to "/connect/new" unless cookies['access_token']
  end
end
