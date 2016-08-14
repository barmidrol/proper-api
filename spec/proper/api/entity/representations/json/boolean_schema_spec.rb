require 'spec_helper'

describe Respect::BooleanSchema::JSON do

  context "representation" do

    it "represents the value of the target object" do
      schema = Respect::BooleanSchema.new
      expect( schema.represent(:json, true) ).to eq(true)
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::BooleanSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::BooleanSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the value of the target object" do
      schema = Respect::BooleanSchema.new
      expect( schema.parse(:json, true) ).to eq(true)
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::BooleanSchema.new

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::BooleanSchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end