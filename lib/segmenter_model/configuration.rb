require 'yaml'

module SegmenterModel
  class Configuration < Hash

    # Default options.
    DEFAULTS = {
      source: Dir.pwd,
      destination: Dir.pwd,
      dic_path: "/usr/local/Cellar/mecab/0.996/lib/mecab/dic/mecab-ipadic-neologd",
      corpus_path: File.join(Dir.pwd, 'texts')
    }

    # load YAML file.
    def read_config_file
      c = clone

      config = YAML.load_file(File.join(DEFAULTS[:source], "segmenter_model.yml"))
      unless config.is_a? Hash
        raise ArgumentError.new("Configuration file: invalid segmenter_model.yml")
      end
      c.merge(config)
    rescue SystemCallError
      puts "Configuration file: not found segmenter_model.yml"
      c
    end

    def symbolize_keys
      inject({}) do |options, (key, value)|
        value = value.symbolize_keys if defined?(value.symbolize_keys)
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end
  end
end
