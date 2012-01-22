class OverviewPointsController < ApplicationController
  # GET /overview_points
  # GET /overview_points.json
  def index
    @overview_points = OverviewPoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @overview_points }
    end
  end

  # GET /overview_points/1
  # GET /overview_points/1.json
  def show
    @overview_point = OverviewPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @overview_point }
    end
  end

  # GET /overview_points/new
  # GET /overview_points/new.json
  def new
    @overview_point = OverviewPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @overview_point }
    end
  end

  # GET /overview_points/1/edit
  def edit
    @overview_point = OverviewPoint.find(params[:id])
  end

  # POST /overview_points
  # POST /overview_points.json
  def create
    @overview_point = OverviewPoint.new(params[:overview_point])

    respond_to do |format|
      if @overview_point.save
        format.html { redirect_to @overview_point, notice: 'Overview point was successfully created.' }
        format.json { render json: @overview_point, status: :created, location: @overview_point }
      else
        format.html { render action: "new" }
        format.json { render json: @overview_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /overview_points/1
  # PUT /overview_points/1.json
  def update
    @overview_point = OverviewPoint.find(params[:id])

    respond_to do |format|
      if @overview_point.update_attributes(params[:overview_point])
        format.html { redirect_to @overview_point, notice: 'Overview point was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @overview_point.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /overview_points/1
  # DELETE /overview_points/1.json
  def destroy
    @overview_point = OverviewPoint.find(params[:id])
    @overview_point.destroy

    respond_to do |format|
      format.html { redirect_to overview_points_url }
      format.json { head :ok }
    end
  end
end
