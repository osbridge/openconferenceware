desc "Benchmark site"
task :bench do
  server = "localhost"
  port = 3000
  #port = 20300
  uris = ["/", "/proposals/1", "/proposals/new"]
  rate = 75
  number = rate * 2

  uris.each do |uri|
   sh "httperf --hog --server #{server} --port #{port} --uri #{uri} --rate #{rate} --num-conn #{number} --num-call 1"
  end
end
