require 'json'
require 'optparse'

OPTIONS = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-t", "--trace", "Trace") do |v|
    OPTIONS[:trace] = v
  end
  opts.on("-i", "--info", "Provide Information") do |v|
    OPTIONS[:info] = v
  end
  opts.on("-j", "--json", "Output JSON") do |v|
    OPTIONS[:json] = v
  end
end.parse!

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
  if data == nil
    cmd = "curl -s #{headers} -X #{method} '#{url}'"
  else
    cmd = "curl -s #{headers} -X #{method} -d '#{JSON.generate(data)}' '#{url}'"
  end

  if !quiet and OPTIONS[:trace]
    puts "Network: ".gray.bold + cmd.gray
  end
  response = `#{cmd}`
end

def get(url)
  curl(url)
end

def post(url, data)
  curl(url, "POST", data)
end

def delete(url)
  curl(url, "DELETE")
end

# DATA ACCESS METHODS

def get_inbox
  inbox = get_lists.detect {|i| i['list_type'] == 'inbox' }
  if OPTIONS[:trace]
    puts "Intermediate JSON: ".gray.bold + JSON.generate(inbox).gray
  end
  inbox
end

def get_lists
  JSON.parse(get(v1url("lists")))
end

def print_list(list)
  bullet = "•".gray
  if OPTIONS[:info]
    info = " (#{list['id']} r#{list['revision']})".gray
  else
    info = ""
  end
  puts "#{bullet} #{list['title']}#{info}"
end

def print_lists
  lists = get_lists
  if OPTIONS[:json]
    puts JSON.pretty_generate(lists)
  else
    lists.each {|i|
      print_list(i)
      #puts "#{i['title']}" + " (#{i['id']} r#{i['revision']})".gray
    }
  end
end

def get_task(task)
  if task.instance_of? Hash
    i = task['id']
  else
    i = task
  end
  JSON.parse(get(v1url("tasks/#{i}")))
end

def get_tasks(list)
  if list.instance_of? Hash
    i = list['id']
  else
    i = list
  end
  JSON.parse(get(v1url("tasks?list_id=#{i}")))
end

def post_task(list, title)
  if list.instance_of? Hash
    i = list['id']
  else 
    i = list
  end
  JSON.parse(post(v1url("tasks"), {list_id: i, title: title}))
end

def print_task(task)
  if OPTIONS[:json]
    puts JSON.pretty_generate(task)
  else
    if task['starred']
      bullet = "*".bold.red
    else
      bullet = "•".gray
    end
    if OPTIONS[:info]
      info = " (#{task['id']} r#{task['revision']})".gray
    else
      info = ""
    end

    puts "#{bullet} #{task['title']}#{info}"
  end

end

def print_tasks(list)
  tasks = get_tasks(list)
  if  OPTIONS[:json] 
    puts JSON.pretty_generate(tasks)
  else
    tasks.each {|i|
      print_task(i)
    }
  end
end

def delete_task(task)
  if task.instance_of? String or task.instance_of? Fixnum
    task = get_task(task)
    if task['error']
      puts "Error: ".bold + task['error']['message']
      return
    end
    if OPTIONS[:trace]
      puts "Intermediate JSON: ".gray.bold + JSON.generate(task).gray
    end
  end

  delete(v1url("tasks/#{task['id']}?revision=#{task['revision']}"))
end