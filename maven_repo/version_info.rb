module MavenRepo

  class VersionInfo

    attr_reader :type, :version

    # @param [String] version
    # @param [Integer] type
    # @param [String] filename_version
    def initialize(version, filename_version, type)
      @version = version
      @filename_version = filename_version
      @type = type
    end

    # @param [ArtifactInfo] artifact_info
    # @return [String]
    def get_file(artifact_info, classifier = nil, extension = 'jar')
      if @type.equal? VersionType::RELEASE
        artifact_info.artifact_id + '-' + @version + (classifier.nil? ? '' : '-' + classifier) + '.' + extension
      elsif @type.equal? VersionType::SNAPSHOT
        artifact_info.artifact_id + '-' + @filename_version + (classifier.nil? ? '' : '-' + classifier) + '.' + extension
      else
        nil
      end
    end

    # @param [ArtifactInfo] artifact_info
    # @param [String] classifier
    # @return [String]
    def get_jar_file(artifact_info, classifier = nil, extension = 'jar')
      if @type.equal? VersionType::RELEASE
        artifact_info.get_path + '/' + @version + '/' + artifact_info.artifact_id + '-' + @version + (classifier.nil? ? '' : '-' + classifier) + '.' + extension
      elsif @type.equal? VersionType::SNAPSHOT
        artifact_info.get_path + '/' + @version + '/' + artifact_info.artifact_id + '-' + @filename_version + (classifier.nil? ? '' : '-' + classifier) + '.' + extension
      else
        nil
      end
    end

    # @param [ArtifactInfo] artifact_info
    # @return [String]
    def get_sources_jar_file(artifact_info)
      get_jar_file(artifact_info, 'sources')
    end

    # @param [ArtifactInfo] artifact_info
    # @return [String]
    def get_pom_file(artifact_info)
      get_jar_file(artifact_info, nil, 'pom')
    end

  end

end
