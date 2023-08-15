require 'test_helper'

class DuplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get duplications_index_url
    assert_response :success
  end

end
