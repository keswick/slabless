class RoutesController < ApplicationController
  # GET /routes
  # GET /routes.json
  
  rescue_from BSON::InvalidObjectId, :with => :render_404
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404

  authorize_actions_for Route, :only => [:new, :create]  
  
  def index
    @bounds = params[:bounds].nil? ? current_user.default_coordinates : parse_coordinates(params[:bounds])
    @routes = current_user.find_my_routes :bounds => @bounds, :filter => params[:filter]
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @routes }
    end
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
    @route = Route.find(params[:id])
    authorize_action_for(@route)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @route }
    end
  end

  # GET /routes/new
  # GET /routes/new.json
  def new
    @route = Route.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @route }
    end
  end

  # GET /routes/1/edit
  def edit
    @route = Route.find(params[:id])
    authorize_action_for(@route)
  end

  # POST /routes
  # POST /routes.json
  def create
    @route = Route.new(params[:route])
    @route.owner_id = current_user.id
    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: 'Route was successfully created.' }
        format.json { render json: @route, status: :created, location: @route }
      else
        format.html { render action: "new" }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /routes/1
  # PUT /routes/1.json
  def update
    @route = Route.find(params[:id])
    authorize_action_for(@route)
    respond_to do |format|
      if @route.update_attributes(params[:route])
        format.html { redirect_to @route, notice: 'Route was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route = Route.find(params[:id])
    @route.destroy

    respond_to do |format|
      format.html { redirect_to routes_url }
      format.json { head :ok }
    end
  end
  
  def export
    @route = Route.find(params[:id])
    send_data @route.to_itn,
      :type => 'text/itn',
      :filename => "#{@route.name}.itn"
  end
   
  private
  
  def parse_coordinates(bounds)
    coordinates = bounds.split(',')
    sw_corner = {:lat => coordinates[0], :lng => coordinates[1]}
    ne_corner = {:lat => coordinates[2], :lng => coordinates[3]}
    return [sw_corner, ne_corner]
  end
   
  def render_404
    render :status => 404, :text => 'not found'
  end
   
end
