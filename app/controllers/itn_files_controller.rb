class ItnFilesController < ApplicationController
  def create
    @route = Route.find(params[:route_id])
    @itn_file = @route.create_itn_file(params[:itn_file])
    redirect_to @route, :notice => "Waypoints added!"
  end
  
end
