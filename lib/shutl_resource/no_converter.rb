module ShutlResource::NoConverter
  extend self

  def to_front_end value; value end
  def to_back_end  value; value end
end
