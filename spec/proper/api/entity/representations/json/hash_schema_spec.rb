require 'spec_helper'

describe Respect::HashSchema::JSON do

  context "representation" do

    it "represents the float value of the target object" do
      schema = Respect::HashSchema.define do |s|
        s.float :x
        s.float :y
      end

      value = {x: 1.0, y: 2.0}

      expect( schema.represent(:json, value) ).to eq( {x: 1.0, y: 2.0} )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HashSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HashSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the float value of the target object" do
      schema = Respect::HashSchema.define do |s|
        s.float :x
        s.float :y
      end

      value = {x: 1.0, y: 2.0}

      expect( schema.parse(:json, value) ).to eq( {x: 1.0, y: 2.0} )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HashSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HashSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

end