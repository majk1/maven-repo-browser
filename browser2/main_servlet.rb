require 'erb'
require 'webrick'
require_relative '../maven_repo/maven_repo'

include MavenRepo
include WEBrick

module Browser2

  class MainServlet < HTTPServlet::AbstractServlet

    def initialize(server, *options)
      super(server, options)
    end

    def do_GET(req, res)

      unless req.query["reindex"].nil?
        exec "../index.sh #{$repository.local_path}"
        $repository.scan
        msg = 'Repository has been reindexed and rescanned'
      end

      unless req.query["rescan"].nil?
        $repository.scan
        msg = 'Repository has been rescanned'
      end

      repository = $repository
      artifacts = $repository.get_sorted_artifacts

      filter_all_selected = ''
      filter_release_selected = ''
      filter_snapshot_selected = ''

      filter = req.query['filter']
      case filter
        when 'all'
          filter_all_selected = ' selected'
        when 'release'
          filter_release_selected = ' selected'
        when 'snapshot'
          filter_snapshot_selected = ' selected'
        else
          filter_all_selected = ' selected'
      end

      search_value = req.query['search']

      File.open('browser2/main.rhtml', 'r') { |f|
        @template = ERB.new(f.read)
      }

      res.body = @template.result(binding)
      res['Content-Type'] = 'text/html'
    end

  end

end
