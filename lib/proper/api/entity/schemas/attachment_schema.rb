module Respect

  #  This is the schema used to represent attachment objects. It automatically
  #  serializes itself as #{name}_url for an existing attachment, and is used
  #  primarily by codegen routines to guess request structure (as the presence
  #  of attached files usually change it a lot)
  #
  #  Usage example:
  #
  #  Respect::HashSchema.define do |s|
  #    s.attachment :avatar
  #  end
  #  
  class AttachmentSchema < AnySchema
  end

end