class Object
  def blank?
    false
  end

  def present?
    true
  end
end

class NilClass
  def blank?
    true
  end

  def present?
    false
  end
end

class String
  def blank?
    return true if self == ''

    false
  end

  def present?
    return false if self == ''

    true
  end
end
