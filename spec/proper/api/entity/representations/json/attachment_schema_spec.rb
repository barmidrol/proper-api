require 'spec_helper'

describe Respect::AttachmentSchema::JSON do

  context "representation" do

    it "represents the URL of the target object" do
      schema = Respect::AttachmentSchema.new
      attachment = double(:attachment, url: "http://google.com")

      expect( schema.represent(:json, attachment) ).to eq("http://google.com")
    end

    it "crashes on nil when options don't allow it" do
      schema = Respect::AttachmentSchema.new

      expect(-> do
        schema.represent( :json, nil )
      end).to raise_error
    end

    it "works with nil when options allow it" do
      schema = Respect::AttachmentSchema.new(allow_nil: true)

      expect( schema.represent(:json, nil) ).to eq( nil )
    end

  end

  context "parse" do

    it "parses the attached as is" do
      schema = Respect::AttachmentSchema.new
      attachment = double(:attachment, url: "http://google.com")

      expect( schema.parse(:json, attachment) ).to eq( attachment )
    end

    it "works with nil" do
      schema = Respect::AttachmentSchema.new(allow_nil: true)

      expect( schema.parse(:json, nil) ).to eq( nil )
    end

  end

end