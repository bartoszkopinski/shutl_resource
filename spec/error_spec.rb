require 'spec_helper'
describe Shutl::Resource::Error do

  specify "it has a body and status" do
    error = Shutl::Resource::Error.new({errors: {base: ["something went wrong"]}}, 500)

    error.body.should == {errors: {base: ["something went wrong"]}}
    error.status.should == 500
  end
end
