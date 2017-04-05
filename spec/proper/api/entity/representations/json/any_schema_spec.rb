require 'spec_helper'

describe Respect::AnySchema::JSON do

  context "representation" do

    it "represents the float array of the target object" do
      schema = Respect::AnySchema.new
      value = [ 1.0 ]

      expect( schema.represent(:json, value) ).to eq( [1.0] )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::AnySchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::AnySchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the float array of the target object" do
      schema = Respect::AnySchema.new
      value = [1.0]

      expect( schema.parse(:json, value) ).to eq( [1.0] )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::AnySchema.new

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::AnySchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end