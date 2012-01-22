require 'test_helper'

class OverviewPointsControllerTest < ActionController::TestCase
  setup do
    @overview_point = overview_points(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:overview_points)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create overview_point" do
    assert_difference('OverviewPoint.count') do
      post :create, overview_point: @overview_point.attributes
    end

    assert_redirected_to overview_point_path(assigns(:overview_point))
  end

  test "should show overview_point" do
    get :show, id: @overview_point.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @overview_point.to_param
    assert_response :success
  end

  test "should update overview_point" do
    put :update, id: @overview_point.to_param, overview_point: @overview_point.attributes
    assert_redirected_to overview_point_path(assigns(:overview_point))
  end

  test "should destroy overview_point" do
    assert_difference('OverviewPoint.count', -1) do
      delete :destroy, id: @overview_point.to_param
    end

    assert_redirected_to overview_points_path
  end
end
