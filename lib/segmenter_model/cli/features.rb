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

        segmenter = SegmenterModel::Segmenter.new(Learner.new)

        File.open(corpus_file_path) do |file|
          file.each_line do |line|
            segmenter.add_sentence(line) do |segment|
              output segment
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

    class Learner
      def add_instance(attributes, label)
        arr = [label.to_s] + attributes
        arr.join(' ')
      end
    end
  end
end
