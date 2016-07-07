
require 'set'
require 'nokogiri'

require_relative 'version_type'
require_relative 'version_info'
require_relative 'artifact_info'

module MavenRepo

  class Repository
    attr_reader :artifacts, :url, :name, :id, :last_scan, :last_index, :local_path

    def initialize(local_path, id, name, url)
      @local_path = local_path
      @id = id
      @name = name
      @url = url
      @artifacts = Set.new
      @last_scan = nil
      @last_index = nil
    end

    def scan
      @artifacts.clear
      Dir[@local_path + '/**/maven-metadata.xml'].each do |dir|
        create_artifact_by_xml(File.open(dir))
      end
      @last_index = File.mtime(@local_path + '/.index/timestamp')
      @last_scan = Time.now
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

    def get_sorted_artifacts
      sorted_artifacts = artifacts.to_a
      sorted_artifacts.sort { |left, right|
        l = left.group_id + ':' + left.artifact_id
        r = right.group_id + ':' + right.artifact_id
        l <=> r
      }
    end

    # @param [ArtifactInfo] artifact_info
    # @param [String] version
    def get_snapshot_metadata_xml_file(artifact_info, version)
      File.open(@local_path + '/' + artifact_info.get_path + '/' + version + '/maven-metadata.xml')
    end

    def create_artifact_by_xml(file)
      xml = Nokogiri::XML(file)
      metadata = xml.at_xpath('//metadata')
      versions = metadata.at_xpath('//versioning/versions')
      unless versions.nil?
        artifact_info = ArtifactInfo.new(metadata.at_xpath('//groupId').content, metadata.at_xpath('//artifactId').content, file.mtime)
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

    private :create_artifact_by_xml
    private :get_snapshot_metadata_xml_file

  end

end

