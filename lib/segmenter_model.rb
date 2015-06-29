# Require all files in directory.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

# rubygems
require 'rubygems'

# internal
require 'segmenter_model/version'
require 'segmenter_model/configuration'
require 'segmenter_model/extractor'
require 'segmenter_model/learner'
require_all 'segmenter_model/cli'

module SegmenterModel
  def self.configuration(options = {})
    unless @config
      config  = Configuration[Configuration::DEFAULTS]
      config  = config.read_config_file
      @config = config.merge(options).symbolize_keys
    end
    @config
  end

  def self.source_path
    config = configuration
    config[:source]
  end

  def self.destination_path
    config = configuration
    config[:destination]
  end

  def self.dic_path
    config = configuration
    config[:dic_path]
  end

  def self.corpus_path
    config = configuration
    config[:corpus_path]
  end
end
