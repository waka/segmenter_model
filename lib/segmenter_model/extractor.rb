module SegmenterModel
  class Extractor
    @@patterns = [
      [/[一二三四五六七八九十百千万億兆]/, 'M'],
      [/[一-龠々〆ヵヶ]/, 'H'],
      [/[ぁ-ん]/, 'I'],
      [/[ァ-ヴーｱ-ﾝﾞｰ]/, 'K'],
      [/[a-zA-Zａ-ｚＡ-Ｚ]/, 'A'],
      [/[0-9０-９]/, 'N'],
    ]

    def type(str)
      res = 'O'
      @@patterns.each do |pattern, t|
        if pattern =~ str
          res = t
          break
        end
      end
      res
    end

    def extract(sentence)
      return unless sentence

      tags = ['U', 'U', 'U']
      chars = ['B3', 'B2', 'B1']
      types = ['O', 'O', 'O']

      sentence.strip.split(' ').each do |word|
        tags.concat(['B'] + ['O'] * (word.size - 1))
        word.each_char do |char|
          chars << char
          types << type(char)
        end
      end

      return if 4 > tags.size
      tags[3] = 'U'
      chars.concat ['E1', 'E2', 'E3']
      types.concat ['O', 'O', 'O']

      size = chars.size - 3
      (4...size).to_a.each do |i|
        label = tags[i] == 'B' ? 1 : -1
        yield feature(attributes(i, tags, chars, types), label)
      end
    end

    def feature(attrs, label)
      arr = [label.to_s] + attrs
      arr.join(' ')
    end

    def attributes(i, tags, chars, types)
      w1 = chars[i-3]
      w2 = chars[i-2]
      w3 = chars[i-1]
      w4 = chars[i]
      w5 = chars[i+1]
      w6 = chars[i+2]
      c1 = types[i-3]
      c2 = types[i-2]
      c3 = types[i-1]
      c4 = types[i]
      c5 = types[i+1]
      c6 = types[i+2]
      p1 = tags[i-3]
      p2 = tags[i-2]
      p3 = tags[i-1]

      [
        'UP1:' + p1,
        'UP2:' + p2,
        'UP3:' + p3,
        'BP1:' + p1 + p2,
        'BP2:' + p2 + p3,
        'UW1:' + w1,
        'UW2:' + w2,
        'UW3:' + w3,
        'UW4:' + w4,
        'UW5:' + w5,
        'UW6:' + w6,
        'BW1:' + w2 + w3,
        'BW2:' + w3 + w4,
        'BW3:' + w4 + w5,
        'TW1:' + w1 + w2 + w3,
        'TW2:' + w2 + w3 + w4,
        'TW3:' + w3 + w4 + w5,
        'TW4:' + w4 + w5 + w6,
        'UC1:' + c1,
        'UC2:' + c2,
        'UC3:' + c3,
        'UC4:' + c4,
        'UC5:' + c5,
        'UC6:' + c6,
        'BC1:' + c2 + c3,
        'BC2:' + c3 + c4,
        'BC3:' + c4 + c5,
        'TC1:' + c1 + c2 + c3,
        'TC2:' + c2 + c3 + c4,
        'TC3:' + c3 + c4 + c5,
        'TC4:' + c4 + c5 + c6,
        'UQ1:' + p1 + c1,
        'UQ2:' + p2 + c2,
        'UQ3:' + p3 + c3,
        'BQ1:' + p2 + c2 + c3,
        'BQ2:' + p2 + c3 + c4,
        'BQ3:' + p3 + c2 + c3,
        'BQ4:' + p3 + c3 + c4,
        'TQ1:' + p2 + c1 + c2 + c3,
        'TQ2:' + p2 + c2 + c3 + c4,
        'TQ3:' + p3 + c1 + c2 + c3,
        'TQ4:' + p3 + c2 + c3 + c4
      ]
    end
  end
end
