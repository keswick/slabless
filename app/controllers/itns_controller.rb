class ItnsController < ApplicationController
  
  layout nil
  
  def new
    @route = Route.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @route }
    end
  end

  def create
    @route = Route.new
    @route.owner_id = current_user.id
    @route.name = params[:itn_file].original_filename[/(.*)(\..*)/,1]
    @route.itn_file = params[:itn_file].read
    @route.visibility = "none"
    debugger
    respond_to do |format|
      if @route.save
        format.html { redirect_to edit_route_path(@route) }
        format.json { render json: @route, status: :created, location: @route }
      else
        format.html { render action: "new" }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

end
