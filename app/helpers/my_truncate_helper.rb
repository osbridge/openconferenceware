module MyTruncateHelper
  # Just like #truncate, but works.
  def my_truncate(string, length=30, omission='...')
    chars = string.chars
    if chars.length > length
      return (string.chars[0...(length - omission.chars.length)].to_s + '...')
    else
      return string
    end
  end
end
