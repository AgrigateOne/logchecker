# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestPlantResourceTypeRoutes < RouteTester

  INTERACTOR = ProductionApp::ResourceTypeInteractor

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Production::Resources::PlantResourceType::Show.stub(:call, bland_page) do
      get 'production/resources/plant_resource_types/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'production/resources/plant_resource_types/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_plant_resource_type).returns(ok_response)
    delete_as_fetch 'production/resources/plant_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_plant_resource_type).returns(bad_response)
    delete_as_fetch 'production/resources/plant_resource_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end
end
