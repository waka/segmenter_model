module SegmenterModel
  module Cli
    #
    # 渡されたコーパスの分かち書きと素性を取り出し、
    # ファイルにして出力する.
    #
    class Features
      def self.process(options = {})
        raise 'not exist file' unless File.exists?(corpus_file_path)
        File.delete(features_file_path) if File.exists?(features_file_path)

        extractor = SegmenterModel::Extractor.new

        File.open(corpus_file_path) do |file|
          file.each_line do |line|
            extractor.extract(line) do |extract|
              output extract
            end
          end
        end
      end

      def self.output(feature)
        return unless feature
        File.open(features_file_path, 'a') do |file|
          file.puts(feature)
        end
      end

      def self.features_file_path
        File.join(SegmenterModel.destination_path, 'features.txt')
      end

      def self.corpus_file_path
        File.join(SegmenterModel.destination_path, 'corpus.txt')
      end
    end
  end
end
