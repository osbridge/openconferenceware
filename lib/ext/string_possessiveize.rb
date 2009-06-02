class String
  
  # Returns the posessive form of a string.
  def possessiveize
    self + "'" + ([115,83].include?(self[-1]) ? '' : 's')
  end
end