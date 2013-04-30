require 'spec_helper'

describe ExportController do
  
  # check that all export methods are correctly behind basic auth
  [:subscription_summary, :seven_day_active_percentage, :warm_conversion_opportunities, :channel_summary].each do |method|
    describe "##{method.to_s}" do
      
      it "should fail if not authenticated" do
        get method
        response.should_not be_success
      end
    
      it "should fail with blank credentials" do
        http_login "", ""
        get method
        response.should_not be_success
      end
    
      it "should fail with bogus credentials" do
        http_login "bogususername", "boguspassword"
        get method
        response.should_not be_success
      end
    
      it "should work with good credentials" do
        http_login AppConfig.export.username, AppConfig.export.password
        get method
        response.should be_success
      end

    end
    
  end
  
end
