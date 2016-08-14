require 'spec_helper'

describe Respect::GeoPointSchema::JSON do

  context "representation" do

    it "represents the geopoint value of the target object" do
      schema = Respect::GeoPointSchema.new
      value = double(latitude: 1, longitude: 2)

      expect( schema.represent(:json, value) ).to eq( { latitude: 1, longitude: 2 } )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::GeoPointSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::GeoPointSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "crashes for now :)" do
      schema = Respect::GeoPointSchema.new

      expect(-> do
        schema.parse( :json, :whatever )
      end).to raise_error
    end

  end

end