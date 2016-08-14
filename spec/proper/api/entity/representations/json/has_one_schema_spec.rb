require 'spec_helper'

class HasOneSchemaTestEntity
  include Proper::Api::Entity

  attr_accessor :x

  schema do
    float :x
  end
end

describe Respect::HasOneSchema::JSON do

  context "representation" do

    it "represents the value using :of option object" do
      schema = Respect::HasOneSchema.new(of: "HasOneSchemaTestEntity")

      e1 = HasOneSchemaTestEntity.new
      e1.x = 1.0

      expect( schema.represent(:json, e1) ).to eq( { x: 1.0 } )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HasOneSchema.new(of: "HasOneSchemaTestEntity")

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HasOneSchema.new(allow_nil: true, of: "HasOneSchemaTestEntity")

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the value using :of option object" do
      schema = Respect::HasOneSchema.new(of: "HasOneSchemaTestEntity")

      result = schema.parse(:json, { x: 1.0 })

      expect( result ).to be_instance_of( HasOneSchemaTestEntity )
      expect( result.x ).to eq(1.0)
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HasOneSchema.new(of: "HasOneSchemaTestEntity")

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HasOneSchema.new(allow_nil: true, of: "HasOneSchemaTestEntity")

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end