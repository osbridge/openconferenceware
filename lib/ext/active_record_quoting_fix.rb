# http://www.mail-archive.com/heroku@googlegroups.com/msg00392.html
#
class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter < ActiveRecord::ConnectionAdapters::AbstractAdapter
  def quote(value, column = nil)
    if (value.kind_of?(String) && column && column.type == :binary) ||
(value.kind_of?(String) && value.include?(0))

"#{quoted_string_prefix}'#{ActiveRecord::ConnectionAdapters::PostgreSQLColumn.string_to_binary(value)}'"
    else
      super
    end
  end
end
