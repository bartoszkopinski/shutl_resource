require File.expand_path('spec/spec_helper')

class QuoteCollection
  include Shutl::Resource::Rest
  base_uri 'http://localhost:9292'
end


class Quote
  include Shutl::Resource::Rest
  base_uri 'http://localhost:9292'
end

describe 'Integration' do
  def set_auth
    Shutl::Auth.config do |c|
      c.url           =  "http://localhost:3000"
      c.client_id     =  "QUOTE_SERVICE_CLIENT_ID"
      c.client_secret =  "QUOTE_SERVICE_CLIENT_SECRET"
    end
  end

  before do
    set_auth
  end


  let(:quote_attributes) do
    {"page"             => "checkout",
     "channel"           => "pos",
     "session"           => "AB12231DECF54BCB",
     "merchant_id"       => "maplins",
     "store_id"          => "map1",
     "delivery_postcode" => "LU1 2LX",
     "basket_value"      => 1295,
     "vehicle_name"      => "Small Van",
     "carrier_name"      => "Rico",
     "products"=>
    [{
      "name"        => "Item",
      "length"      => 1,
      "width"       => 1,
      "height"      => 1,
      "weight"      => 2,
      "quantity"    => 1
    }]
    }
  end


  specify do
    VCR.use_cassette 'create_quote' do
      @quote_collection = QuoteCollection.create quote_attributes
    end

    VCR.use_cassette 'find quote' do
      Quote.find @quote_collection.asap_quote[:id]
    end
  end
end
