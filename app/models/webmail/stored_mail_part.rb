class Webmail::StoredMailPart
  attr_accessor :section, :part

  delegate :attachment?, :filename, :read, :decoded, to: :part

  def initialize(part, section = nil)
    self.section = section
    self.part = part
  end

  def content_type
    part.content_type.downcase
  end

  def image?
    part.main_type.casecmp('IMAGE') == 0
  end

  def link_target
    image? ? '_blank' : nil
  end

  def size
    part.body.raw_source.size
  end
end
