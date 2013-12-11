module OpenConferenceWare
  module LocalcssHelper
    # Use local CSS files? These are used if the server is running the
    # "development" environment, or if there is a "localcss.flag" file, or the
    # LOCALCSS environmental variable is set.
    def localcss?
      return Rails.env == "development" || ENV['LOCALCSS'] || File.exist?(File.join(Rails.root, "localcss.flag"))
    end
  end
end
