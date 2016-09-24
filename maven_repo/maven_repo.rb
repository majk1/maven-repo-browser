
require 'set'
require 'nokogiri'

require_relative 'version_type'
require_relative 'version_info'
require_relative 'artifact_info'

module MavenRepo

  class Repository
    attr_reader :artifacts

    def initialize(local_path)
      @local_path = local_path
      @artifacts = Set.new
    end

    def scan
      @artifacts.clear
      Dir[@local_path + '/**/maven-metadata.xml'].each do |dir|
        create_artifact_by_xml(File.open(dir))
      end
    end

    def print
      STDERR.puts "artifact count: #{@artifacts.size}"
      @artifacts.each do |ar|
        STDERR.puts '  groutId:    ' + ar.group_id
        STDERR.puts '  artifactId: ' + ar.artifact_id
        STDERR.puts '  versions:'
        ar.versions.each do |ver|
          STDERR.puts '    ' + ver.version
          STDERR.puts '    ' + (ver.type == VersionType::RELEASE ? 'RELEASE' : 'SNAPSHOT')
          STDERR.puts '    ' + ver.get_jar_file(ar)
          STDERR.puts '    ' + ver.get_sources_jar_file(ar)
          STDERR.puts '    ' + ver.get_pom_file(ar)
        end
      end
    end

    # @param [ArtifactInfo] artifact_info
    # @param [String] version
    private def get_snapshot_metadata_xml_file(artifact_info, version)
      File.open(@local_path + '/' + artifact_info.get_path + '/' + version + '/maven-metadata.xml')
    end

    private def create_artifact_by_xml(file)
      xml = Nokogiri::XML(file)
      metadata = xml.at_xpath('//metadata')
      versions = metadata.at_xpath('//versioning/versions')
      unless versions.nil?
        artifact_info = ArtifactInfo.new(metadata.at_xpath('//groupId').content, metadata.at_xpath('//artifactId').content)
        is_release = !metadata.at_xpath('//versioning/release').nil?

        metadata.xpath('//versions/version').each do |version_element|
          version = version_element.content
          if is_release
            artifact_info.versions << VersionInfo.new(version, version, VersionType::RELEASE)
          else
            version_xml = Nokogiri::XML(get_snapshot_metadata_xml_file(artifact_info, version))
            value = version_xml.at_xpath('//metadata/versioning/snapshotVersions/snapshotVersion/value')
            unless value.nil?
              artifact_info.versions << VersionInfo.new(version, value.content, VersionType::SNAPSHOT)
            end
          end
        end

        @artifacts.add(artifact_info)
      end
    end

  end

end

