require "net/http"
require "tty-markdown"
require "reverse_markdown"
require "debug"
# URL of the documentation website
url =
  "https://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html"

# Make an HTTP GET request to fetch the HTML content
response = Net::HTTP.get_response(URI(url))

# Check if the request was successful
if response.code == "200"
  result = ReverseMarkdown.convert(response.body).inspect
  #  File.open("documentation.md", "w") { |file| file.write(result) }
  parsed = TTY::Markdown.parse(result)
  puts parsed
else
  puts "Failed to fetch the documentation. Error code: #{response.code}"
end
