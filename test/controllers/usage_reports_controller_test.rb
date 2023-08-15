require 'test_helper'

class UsageReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get usage_reports_index_url
    assert_response :success
  end

end
