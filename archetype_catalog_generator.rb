require_relative 'maven_repo/maven_repo'

include MavenRepo

@repo_path = nil
@archetype_cat_path = nil

def main
  process_parameters(ARGV)

  repo = Repository.new @repo_path, 'dummy-repo-id', 'dummy-repository', 'httx://dummy.maven.repo'
  repo.generate_archetype_catalog @archetype_cat_path

end

def process_parameters(argv)
  i = 0
  until argv[i].nil?
    arg = argv[i]
    case arg
      when '--repo-path'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid repository path')
          exit(-1)
        else
          @repo_path = param
        end
      when '--archetype-catalog-path'
        param = argv[i+1]
        if param.start_with? '-'
          STDERR.puts('Invalid archetype catalog path')
          exit(-1)
        else
          @archetype_cat_path = param
        end
    end
    i += 1
  end

  if @repo_path.nil?
    STDERR.puts('Repository path is mandatory, define with --repo-path')
    exit(-1)
  end

  if @archetype_cat_path.nil?
    STDERR.puts('Archetype catalog xml path is mandatory, define with --archetype-catalog-path')
    exit(-1)
  end

end

main
