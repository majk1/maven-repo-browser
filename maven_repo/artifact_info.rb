module MavenRepo

  class ArtifactInfo

    attr_accessor :versions, :name
    attr_reader :artifact_id, :group_id

    def initialize(group_id, artifact_id)
      @group_id = group_id
      @artifact_id = artifact_id
      @versions = []
      @name = ''
    end

    def get_path
      group_id.gsub('.', '/') + '/' + artifact_id
    end

  end

end

