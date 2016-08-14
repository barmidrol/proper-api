require 'spec_helper'

describe Respect::DateSchema::JSON do

  context "representation" do

    it "represents the UTC value of the target object" do
      schema = Respect::DateSchema.new
      value = Time.now

      expect( schema.represent(:json, value) ).to eq( value.to_date.strftime("%Y-%m-%d") )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::DateSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::DateSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the UTC value of the target object" do
      schema = Respect::DateSchema.new
      value = Time.now

      expect( schema.parse(:json, value.to_date.strftime("%Y-%m-%d")) ).to eq( value.to_date )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::DateSchema.new

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::DateSchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end