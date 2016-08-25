require 'spec_helper'

describe Respect::EnumSchema::JSON do

  module ::EnumSchemaValuesTest
    ASD = "asd"
    QWE = "qwe"
  end

  context "representation" do

    it "represents the float value of the target object" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")
      value = "asd"

      expect( schema.represent(:json, value) ).to eq( "asd" )
    end

    it "crashes on values not allowed by schema" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")

      expect(-> do
        schema.represent( :json, "def" )
      end).to raise_error
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::EnumSchema.new(allow_nil: true, from: "EnumSchemaValuesTest")

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the float value of the target object" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")
      value = "asd"

      expect( schema.parse(:json, value) ).to eq( "asd" )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "crashes on values not allowed by schema" do
      schema = Respect::EnumSchema.new(from: "EnumSchemaValuesTest")

      expect(-> do
        schema.parse( :json, "def" )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::EnumSchema.new(allow_nil: true, from: "EnumSchemaValuesTest")

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end