require 'json'
require 'optparse'

OPTIONS = {}
OPTIONS_PARSER = OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"
  opts.on("-v", "--verbose", "Show verbose statements") do |v|
    OPTIONS[:verbose] = v
  end
  opts.on("-i ID", "--id ID", Integer, "Object identifier") do |v|
    OPTIONS[:id] = v
  end
  opts.on("-r REVISION", "--revision REVISION", Integer, "Object identifier") do |v|
    OPTIONS[:revision] = v
  end
  opts.on("-j ID", "--list-id ID", Integer, "Object identifier") do |v|
    OPTIONS[:list_id] = v
  end
  opts.on("-t TITLE", "--title TITLE", "Title for a task") do |v|
    OPTIONS[:title] = v
  end
  opts.on("-u URL", "--url URL", "Webhook URL") do |v|
    OPTIONS[:url] = v
  end
  opts.on("-d CONFIG", "--CONFIG CONFIG", "Configuration") do |v|
    OPTIONS[:config] = v
  end
  opts.on("-p TYPE", "--processor-type TYPE", "Processor Type") do |v|
    OPTIONS[:processor_type] = v
  end
  opts.on("-s", "--[no-]star", "Star status") do |v|
    OPTIONS[:starred] = v
  end
  opts.on("-c", "--[no-]complete", "Completed status") do |v|
    OPTIONS[:completed] = v
  end
end

def parse_options
  OPTIONS_PARSER.parse!
end

class String
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def bold;           "\033[1m#{self}\033[22m" end
  def reverse_color;  "\033[7m#{self}\033[27m" end
end

def client_id
  return ENV['WLIST_CLIENT_ID'] if ENV['WLIST_CLIENT_ID']
  puts "Missing $WLIST_CLIENT_ID in environment"
  puts "Visit https://developer.wunderlist.com/applications and create an app!"
  exit -1
end

def access_token
  return ENV['WLIST_ACCESS_TOKEN'] if ENV['WLIST_ACCESS_TOKEN']
  puts "Missing $WLIST_ACCESS_TOKEN in environment."
  exit -1
end

def access_headers
  "-H 'Content-Type: application/json' -H 'X-Client-ID: #{client_id}' -H 'X-Access-Token: #{access_token}'"
end

def v1url(resource)
  "https://a.wunderlist.com/api/v1/#{resource}"
end

# NETWORK ACCESS METHODS

def curl(url, method="GET", data=nil, headers=access_headers, quiet=false)
  cmd = "-s #{headers}"
  cmd << " -d '#{JSON.generate(data)}'" if data != nil
  cmd << " -X #{method} '#{url}'"

  if !quiet and OPTIONS[:verbose]
    puts "curl ".gray.bold + cmd.gray
  end
  response = `curl #{cmd}`
end

def get(path)
  url = v1url(path)
  response = curl(url, "GET")
  JSON.parse(response)
end

def post(path, data)
  url = v1url(path)
  response = curl(url, "POST", data)
  JSON.parse(response)
end

def patch(path, data)
  url = v1url(path)
  response = curl(url, "PATCH", data)
  JSON.parse(response)
end

def delete(path)
  url = v1url("#{path}")
  response = curl(url, "DELETE")
  if response != ""
    JSON.parse(response)
  else
    nil
  end
end

# INBOX HELPER

def get_inbox_id
  lists = get("lists")
  inbox = lists.detect {|i| i['list_type'] == 'inbox' }['id']
  if OPTIONS[:verbose]
    puts "scanned ".gray.bold + "#{lists.size} lists for list_type of inbox".gray
    puts "inbox id: ".gray.bold + "#{inbox}".gray
  end
  inbox
end
