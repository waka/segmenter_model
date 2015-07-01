module SegmenterModel
  class Learner
    SPLITTER = ' '

    attr_reader :labels, :instances, :dignities, :features, :models

    def initialize(count: 100, threshold: 0.01)
      @count = count
      @threshold = threshold

      @labels    = []
      @instances = []
      @dignities = []

      @features = []
      @models   = []
    end

    def init_features_and_models(file_path)
      map = {}

      File.open(file_path) do |file|
        file.each_line do |line|
          arr = line.split(SPLITTER)
          arr[1..-1].each do |a|
            map[a] = 0.0
          end
        end
      end
      map[''] = 0.0

      Hash[map.sort].each do |k, v|
        @features << k
        @models << v
      end
    end

    def init_instances(file_path)
      b = bias
      instances_buf = []

      File.open(file_path) do |file|
        file.each_line do |line|
          score = b

          start_index = instances_buf.size > 0 ? instances_buf.size - 1 : 0

          arr = line.split(SPLITTER)
          label = arr[0].to_i
          @labels << label
          arr[1..-1].each do |a|
            index = @features.find_index{ |feature| feature == a }
            instances_buf << index
            score += @models[index]
          end

          last_index = instances_buf.size > 0 ? instances_buf.size - 1 : 0
          r = instances_buf[start_index..last_index].dup.sort
          @instances << r
          @dignities << Math.exp(-1 * label * score * 2)
        end
      end
    end

    def bias
      value = 0.0;
      @models.each do |model|
        value -= model
      end
      value / 2
    end

    def learn!
      h_best = 0
      e_best = 0.5
      a = 0
      a_exp = 1

      trainer = Trainer.new(self)

      @count.times do |time|
        # update & calculate errors
        trainer.train(h_best, a_exp)
        sum = trainer.sum
        sum_plus = trainer.sum_plus

        # select best classifier
        e_best = sum / sum_plus
        h_best = 0
        (1..@features.size-1).to_a.each do |i|
          e = trainer.errors[i]
          e = (e + sum_plus) / sum
          if (0.5 - e).abs > (0.5 - e_best).abs
            h_best = i
            e_best = e
          end
        end
        break if @threshold > (0.5 - e_best).abs

        e_best = 1e-10 if 1e-10 > e_best
        e_best = 1 - 1e-10 if e_best > (1 - 1e-10)

        # update model
        a = 0.5 * Math.log((1 - e_best) / e_best);
        a_exp = Math.exp(a);
        @models[h_best] += a;

        # normalize
        @instances.each_with_index do |instance, i|
          @dignities[i] /= sum
        end
      end
    end

    def create_model
      b = -1 * @models[0]
      @features.each_with_index do |feature, i|
        model = @models[i]
        next if model == 0.0
        yield "#{feature} #{model}"
        b -= model
      end
      yield "#{(b / 2)}"
    end
  end

  class Trainer
    attr_accessor :sum, :sum_plus, :errors

    def initialize(learner)
      @sum = 0.0;
      @sum_plus = 0.0;
      @errors = []
      @learner = learner
    end

    def train(best, exp)
      @learner.instances.each_with_index do |range, i|
        label = @learner.labels[i]
        index = range.find_index{ |num| num >= best }
        prediction = (range[index] == range.last || range[index] != best) ? -1 : 1

        if 0 > label * prediction
          @learner.dignities[i] *= exp
        else
          @learner.dignities[i] /= exp
        end

        @sum += @learner.dignities[i]
        @sum_plus += @learner.dignities[i] if label > 0

        d = @learner.dignities[i] * label
        range.each do |r|
          @errors[r] = d
        end
      end
    end
  end
end
