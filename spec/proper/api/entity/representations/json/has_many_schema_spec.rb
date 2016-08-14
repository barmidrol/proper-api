require 'spec_helper'

class HasManySchemaTestEntity
  include Proper::Api::Entity

  attr_accessor :x

  schema do
    float :x
  end
end

describe Respect::HasManySchema::JSON do

  context "representation" do

    it "represents the array of values using :of option object" do
      schema = Respect::HasManySchema.new(of: "HasManySchemaTestEntity")

      e1 = HasManySchemaTestEntity.new
      e1.x = 1.0

      e2 = HasManySchemaTestEntity.new
      e2.x = 2.0

      expect( schema.represent(:json, [ e1, e2 ]) ).to eq( [{ x: 1.0 }, { x: 2.0 }] )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HasManySchema.new(of: "HasManySchemaTestEntity")

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HasManySchema.new(allow_nil: true, of: "HasManySchemaTestEntity")

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parsing" do

    it "parses the array of values using :of option object" do
      schema = Respect::HasManySchema.new(of: "HasManySchemaTestEntity")

      result = schema.parse(:json, [{ x: 1.0 }, { x: 2.0 }])

      expect( result.size ).to eq(2)

      expect( result[0] ).to be_instance_of(HasManySchemaTestEntity)
      expect( result[0].x ).to eq(1.0)

      expect( result[1] ).to be_instance_of(HasManySchemaTestEntity)
      expect( result[1].x ).to eq(2.0)
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::HasManySchema.new(of: "HasManySchemaTestEntity")

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::HasManySchema.new(allow_nil: true, of: "HasManySchemaTestEntity")

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end