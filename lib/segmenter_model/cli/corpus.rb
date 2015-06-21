module SegmenterModel
  module Cli
    require 'mecab'
    require 'moji'

    # 渡されたテキストファイルをmecab+ipadic-neologdで解析した結果を、
    # スペースで区切ったファイルにして出力する.
    class Corpus
      # エントリポイント
      def self.process(options = {})
        f = File.join(SegmenterModel.destination_path, 'corpus.txt')
        File.delete(f) if File.exists?(f)

        files = options[:file] ? [options[:file]] : Dir.glob(SegmenterModel.corpus_path + "/*.txt")
        files.each do |file|
          sentence = load_file(file)
          words = parse(normalize(sentence))
          output join_by_space(words)
        end
      end

      def self.load_file(file_path)
        File.read(file_path)
      end

      # 解析前にマッチしやすくするため正規化を行う
      def self.normalize(sentence)
        normalize_for_neologd(sentence)
      end

      # 結果3種を配列にする.
      def self.parse(sentence)
        mt = MeCab::Tagger.new("Ochasen -d #{SegmenterModel.dic_path}")
        node = mt.parseToNode(sentence)

        words = []
        begin
          node = node.next
          words << node.feature.split(',').reverse[0..2]
        end until node.next.feature.include?("BOS/EOS")
        words
      end

      # wordsをスペース区切りに
      def self.join_by_space(words)
        words.flatten!.uniq!.join(' ')
      end

      # corpus.txtとして出力
      def self.output(corpus)
        file = File.join(SegmenterModel.destination_path, 'corpus.txt')
        File.open(file, 'a') do |file|
          file.write(corpus)
        end
      end

      private

      # https://github.com/neologd/mecab-ipadic-neologd/wiki/Regexp.ja
      def self.normalize_for_neologd(norm)
        norm.tr!("０-９Ａ-Ｚａ-ｚ", "0-9A-Za-z")
        norm = Moji.han_to_zen(norm, Moji::HAN_KATA)
        hypon_reg = /(?:˗|֊|‐|‑|‒|–|⁃|⁻|₋|−)/
        norm.gsub!(hypon_reg, "-")
        choon_reg = /(?:﹣|－|ｰ|—|―|─|━)/
        norm.gsub!(choon_reg, "ー")
        chil_reg = /(?:~|∼|∾|〜|〰|～)/
        norm.gsub!(chil_reg, '')
        norm.gsub!(/[ー]+/, "ー")
        norm.tr!(%q{!"#$%&'()*+,-.\/:;<=>?@[\]^_`{|}~｡､･｢｣"}, %q{！”＃＄％＆’（）＊＋，−．／：；＜＝＞？＠［￥］＾＿｀｛｜｝〜。、・「」})
        norm.gsub!(/　/, " ")
        norm.gsub!(/ {1,}/, " ")
        norm.gsub!(/^[ ]+(.+?)$/, "\\1")
        norm.gsub!(/^(.+?)[ ]+$/, "\\1")
        while norm =~ %r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}
          norm.gsub!( %r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}, "\\1\\2")
        end
        while norm =~ %r{([\p{InBasicLatin}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}
          norm.gsub!(%r{([\p{InBasicLatin}]+)[ ]{1}([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)}, "\\1\\2")
        end
        while norm =~ %r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InBasicLatin}]+)}
          norm.gsub!(%r{([\p{InCJKUnifiedIdeographs}\p{InHiragana}\p{InKatakana}\p{InHalfwidthAndFullwidthForms}\p{InCJKSymbolsAndPunctuation}]+)[ ]{1}([\p{InBasicLatin}]+)}, "\\1\\2")
        end
        norm.tr!(
          %q{！”＃＄％＆’（）＊＋，−．／：；＜＞？＠［￥］＾＿｀｛｜｝〜},
          %q{!"#$%&'()*+,-.\/:;<>?@[\]^_`{|}~}
        )
        norm
      end
    end
  end
end
