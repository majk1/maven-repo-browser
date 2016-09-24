#!/usr/bin/env ruby

require 'cgi/util'
require_relative 'browser/browser'
require_relative 'maven_repo/maven_repo'

@maven_repo_path = '/maven2/web'
@url_prefix = ''

def my_callback(header_info)
  items = Browser::Browser::extract_path(header_info.get_path)

  base_index = @url_prefix.empty? ? 0 : 1

  filter = 'all'
  search = ''
  download = ''

  unless items[base_index].nil?
    filter = items[base_index]
  end

  unless items[base_index+1].nil?
    search = CGI::unescape(items[base_index+1])
  end

  unless items[base_index+2].nil?
    download = items[base_index+2]
  end

  type_all_selected = filter == 'all' ? ' selected' : ''
  type_release_selected = filter == 'release' ? ' selected' : ''
  type_snapshot_selected = filter == 'snapshot' ? ' selected' : ''

  # asdasdasd

  repository = MavenRepo::Repository.new(@maven_repo_path)
  repository.scan

  # repository.print

  response = '<html>
<head>
  <title>Maven repository browser</title>
  <script type="text/javascript">
    function filter() {
      var type = document.getElementById(\'type\').value;
      var search = document.getElementById(\'search\').value;
      location.href = window.location.protocol + \'//\' + window.location.host + \'/\' + \'' + @url_prefix + '\' + type + \'/\' + search;
    }
  </script>
  <style type="text/css">
    .collapse {
      cursor: pointer;
    }
    .collapse + input {
      display: none;
    }
    .collapse + input + div {
      display: none;
    }
    .collapse + input:checked + div {
      display: block;
    }
  </style>
</head>
<body>

  <h1>Maven repository browser</h1>
  <hr/>

  <div style="font-family: sans-serif; font-size: 12px">

  Filter: <select id="type" name="type">
    <option value="all"' + type_all_selected + '>All</option>
    <option value="release"' + type_release_selected + '>Releases</option>
    <option value="snapshot"' + type_snapshot_selected + '>Snapshots</option>
  </select>
  Search: <input id="search" name="search" type="text" value="' + search + '"/>

  <input type="button" value="Filter" onClick="filter()"/>

  <script type="text/javascript">
    var search = document.getElementById(\'search\');

    search.addEventListener("keyup", function(event) {
        event.preventDefault();
        if (event.keyCode == 13) {
            filter();
        }
    });

    search.focus();

  </script>

  <hr/>

'
  id_counter = 1

  repository.artifacts.each do |artifact|
    artifact.versions.each do |version_info|
      if (filter != 'all') &&
          (filter == 'release' && version_info.type != MavenRepo::VersionType::RELEASE) ||
          (filter == 'snapshot' && version_info.type != MavenRepo::VersionType::SNAPSHOT)
        next
      end

      unless search.empty?
        long_name = artifact.group_id + ':' + artifact.artifact_id + ':' + version_info.version
        unless long_name.downcase.include? search.downcase
          next
        end
      end

      response << '  <div>
    <label class="collapse" for="_' + id_counter.to_s + '">&#x25B6; '+ artifact.group_id + ':<strong>' + artifact.artifact_id + '</strong>:' + version_info.version + '</label><input id="_' + id_counter.to_s + '" type="checkbox"/>
    <div>
      <pre>
  &lt;repositories&gt;
    &lt;repository&gt;
      &lt;id&gt;majkis-repo&lt;/id&gt;
      &lt;name&gt;Majki\'s repository&lt;/name&gt;
      &lt;url&gt;http://maven.majki.org&lt;/url&gt;
    &lt;/repository&gt;
  &lt;/repositories&gt;

  &lt;dependencies&gt;
    &lt;dependency&gt;
      &lt;groupId&gt;<strong>' + artifact.group_id + '</strong>&lt;/groupId&gt;
      &lt;artifactId&gt;<strong>' + artifact.artifact_id + '</strong>&lt;/artifactId&gt;
      &lt;version&gt;<strong>' + version_info.version + '</strong>&lt;/version&gt;</strong>
    &lt;/dependency&gt;
  &lt;/dependencies&gt;
      </pre>
'

      # TODO: parameterize maven repo url

      url = version_info.get_pom_file(artifact)
      response << '      <a href="http://maven.majki.org/' + url + '">' + version_info.get_file(artifact, nil, 'pom') + '</a></br>'
      url = version_info.get_jar_file(artifact)
      response << '      <a href="http://maven.majki.org/' + url + '">' + version_info.get_file(artifact) + '</a></br>'
      url = version_info.get_sources_jar_file(artifact)
      unless url.nil?
        response << '      <a href="http://maven.majki.org/' + url + '">' + version_info.get_file(artifact, 'sources') + '</a></br>'
      end

      response <<
'
      <br/>
    </div>
  </div>
'
      id_counter += 1
    end
  end

  response << '

  </div>

</body>
</html>
'

  response
end

def gen_path(group_id, artifact_id, version)
  @maven_repo_path + '/' + group_id.gsub('.', '/') + '/' + artifact_id + '/' + version + '/' + artifact_id + '-' + version + '.jar'
end

browser = Browser::Browser.new
browser.host = ARGV[0] unless ARGV[0].nil?
browser.port = ARGV[1].to_i unless ARGV[1].nil?
browser.callback = self.method(:my_callback)

@maven_repo_path = ARGV[2] unless ARGV[2].nil?
@url_prefix = ARGV[3] unless ARGV[3].nil?

unless @url_prefix.empty?
  unless @url_prefix.end_with? '/'
    @url_prefix += '/'
  end
end

STDOUT.puts("Repository path is \"#{@maven_repo_path}\"")
STDOUT.puts("URL prefix is \"#{@url_prefix}\"")

browser.start
