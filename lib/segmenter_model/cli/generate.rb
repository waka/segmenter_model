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

        trainer = SegmenterModel::Trainer.new
      end

      def self.output(train)
        return unless feature
        File.open(model_file_path, 'a') do |file|
          file.puts(train)
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
