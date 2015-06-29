module SegmenterModel
  module Cli
    #
    # 分かち書きと素性から学習データを
    # ファイルにして出力する.
    #
    class Generator
      def self.process(options = {})
        raise 'not exist file' unless File.exists?(features_file_path)
        File.delete(model_file_path) if File.exists?(model_file_path)

        learner = SegmenterModel::Learner.new
        learner.pre_process(features_file_path)

        learner.learn do |trained|
          output trained
        end
      end

      def self.output(trained)
        return unless feature
        File.open(model_file_path, 'a') do |file|
          file.puts(trained)
        end
      end

      def self.model_file_path
        File.join(SegmenterModel.destination_path, 'model')
      end

      def self.features_file_path
        File.join(SegmenterModel.destination_path, 'features.txt')
      end
    end
  end
end
