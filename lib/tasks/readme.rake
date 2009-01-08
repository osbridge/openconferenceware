desc "Generate README as HTML"
file "README.html" => "README.markdown" do
  require 'rubygems'
  require 'maruku'
  File.open("README.html", "w+") do |handle|
    handle.write(Maruku.new(File.read("README.markdown")).to_html_document)
  end
end
