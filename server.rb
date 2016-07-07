# web server

require 'webrick'
require 'logger'
require_relative 'maven_repo/maven_repo'
require_relative 'browser2/main_servlet'

include WEBrick
include MavenRepo
include Browser2

@host = 'localhost'
@port = 9999
@repo_path = nil
@repo_id = nil
@repo_name = nil
@repo_url = nil

$repository

def main
  logger = Logger.new(STDERR)
  logger.formatter = proc do |severity, datetime, progname, msg|
    "[#{datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')}] #{severity} - #{progname}: #{msg}\n"
  end
  process_parameters(ARGV)

  logger.info('Starting maven repository browser')
  logger.info('Repository info:')
  logger.info("  local path: #{@repo_path}")
  logger.info("          id: #{@repo_id}")
  logger.info("        name: #{@repo_name}")
  logger.info("         URL: #{@repo_url}")

  $repository = Repository.new @repo_path, @repo_id, @repo_name, @repo_url
  $repository.scan

  server = HTTPServer.new :Port => @port, :BindAddress => @host
  trap 'INT' do
    server.shutdown
  end
  server.mount('/', MainServlet)
  server.start
end

def process_parameters(argv)
  i = 0
  until argv[i].nil?
    arg = argv[i]
    case arg
      when '-h', '--host'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid host')
          exit(-1)
        else
          @host = param
        end
      when '-p', '--port'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid port')
          exit(-1)
        else
          @port = param.to_i
        end
      when '--repo-path'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid repository path')
          exit(-1)
        else
          @repo_path = param
        end
      when '--repo-id'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid repository id')
          exit(-1)
        else
          @repo_id = param
        end
      when '--repo-name'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid repository name')
          exit(-1)
        else
          @repo_name = param
        end
      when '--repo-url'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid repository url')
          exit(-1)
        else
          @repo_url = param
        end
    end
    i += 1
  end

  if @repo_path.nil?
    STDERR.puts('Repository path is mandatory, define with --repo-path')
    exit(-1)
  end

  if @repo_id.nil?
    STDERR.puts('Repository ID is mandatory, define with --repo-id')
    exit(-1)
  end

  if @repo_name.nil?
    STDERR.puts('Repository name is mandatory, define with --repo-name')
    exit(-1)
  end

  if @repo_url.nil?
    STDERR.puts('Repository URL is mandatory, define with --repo-url')
    exit(-1)
  end

end

main
