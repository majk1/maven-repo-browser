module MavenRepo

  class ArtifactInfo

    attr_accessor :versions
    attr_reader :artifact_id, :group_id, :deploy_time

    def initialize(group_id, artifact_id, deploy_time)
      @group_id = group_id
      @artifact_id = artifact_id
      @deploy_time = deploy_time
      @versions = []
    end

    def get_path
      group_id.gsub('.', '/') + '/' + artifact_id
    end

  end

end

