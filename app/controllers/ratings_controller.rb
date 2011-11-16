class RatingsController < ApplicationController
  def create
    @route = Route.find(params[:route_id])
    @rating = @route.ratings.create!(params[:rating])
    redirect_to @route, :notice => "Rating Added"
  end
end
