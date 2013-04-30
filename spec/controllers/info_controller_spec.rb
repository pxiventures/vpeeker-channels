require 'spec_helper'

describe InfoController do

  describe "#signup" do
    it "should render" do
      get :signup
      response.should be_success
    end
  end

end
