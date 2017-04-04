require 'spec_helper'

describe Respect::ArraySchema::JSON do

  context "representation" do

    it "represents the float array of the target object" do
      schema = Respect::ArraySchema.new
      value = [ 1.0 ]

      expect( schema.represent(:json, value) ).to eq( [1.0] )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::ArraySchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::ArraySchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

    it "represents inner entities" do
      schema = Respect::ArraySchema.new(allow_nil: true)

      klass = Class.new do
        include Proper::Api::Entity
        schema(fields: true) do
          integer :x
          string  :y
        end
      end

      array = []

      array << klass.new
      array.last.x = 1
      array.last.y = "asd"  

      array << klass.new
      array.last.x = 2
      array.last.y = "def"    

      result = schema.represent(:json, array)

      expect( result ).to be_is_a(Array)
      expect( result.size ).to eq(2)

      expect( result[0][:"x"] ).to eq(1)
      expect( result[0][:"y"] ).to eq("asd")

      expect( result[1][:"x"] ).to eq(2)
      expect( result[1][:"y"] ).to eq("def")
    end

  end

  context "parsing" do

    it "parses the float array of the target object" do
      schema = Respect::ArraySchema.new
      value = [1.0]

      expect( schema.parse(:json, value) ).to eq( [1.0] )
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::ArraySchema.new

      expect(-> do
        schema.parse( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::ArraySchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end