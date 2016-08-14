require 'spec_helper'

describe Respect::InstantSchema::JSON do

  context "representation" do

    it "represents the UTC value of the target object" do
      schema = Respect::InstantSchema.new
      value = Time.now

      expect( schema.represent(:json, value) ).to eq( value.utc.strftime("%Y-%m-%dT%H:%M:%SZ") )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::InstantSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::InstantSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "represents the UTC value of the target object" do
      schema = Respect::InstantSchema.new

      value = Time.parse( Time.now.strftime("%Y-%m-%dT%H:%M:%SZ") )

      expect( schema.parse(:json, value.utc.strftime("%Y-%m-%dT%H:%M:%SZ")) ).to eq( value.utc )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::InstantSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::InstantSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

end