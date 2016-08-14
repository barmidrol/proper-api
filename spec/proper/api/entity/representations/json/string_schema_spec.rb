require 'spec_helper'

describe Respect::StringSchema::JSON do

  context "representation" do

    it "represents the float value of the target object" do
      schema = Respect::StringSchema.new
      value = "asd"

      expect( schema.represent(:json, value) ).to eq( "asd" )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::StringSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::StringSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the float value of the target object" do
      schema = Respect::StringSchema.new
      value = "asd"

      expect( schema.parse(:json, value) ).to eq( "asd" )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::StringSchema.new

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::StringSchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end