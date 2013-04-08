module MyTruncateHelper
  # Just like #truncate, but works.
  def my_truncate(string, length=30, omission='...')
    return nil if string.blank?
    chars = string.mb_chars
    if chars.length > length
      return (string.mb_chars[0...(length - omission.mb_chars.length)].to_s + '...')
    else
      return string
    end
  end
end
