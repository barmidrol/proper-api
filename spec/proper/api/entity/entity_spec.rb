require 'spec_helper'

describe Proper::Api::Entity do

  context "schema definition" do

    it "generates attr_accessors for schema fields" do
      klass = Class.new do
        include Proper::Api::Entity
        schema(fields: true) do
          integer :x
          string  :y
        end
      end

      instance = klass.new
      instance.x = 1
      instance.y = "asd"

      expect( instance.x ).to eq(1)
      expect( instance.y ).to eq("asd")
    end

  end

  context "representation" do

    context "json" do

      it "represents simple objects" do
        klass = Class.new do
          include Proper::Api::Entity
          schema(fields: true) do
            integer :x
            string  :y
          end
        end

        instance = klass.new
        instance.x = 1
        instance.y = "asd"

        expect( instance.represent(:json) ).to eq({x: 1, y: "asd"})
      end

      it "represents complex objects" do
        nested = Class.new do
          include Proper::Api::Entity
          schema(fields: true) do
            integer :y
          end
        end

        klass = Class.new do
          include Proper::Api::Entity
          schema(fields: true) do
            integer :x
            has_one :y, of: nested
          end
        end

        instance = klass.new
        instance.x = 1
        instance.y = nested.new
        instance.y.y = 2

        expect( instance.represent(:json) ).to eq({x: 1, y: {y: 2}})
      end

    end

  end

end