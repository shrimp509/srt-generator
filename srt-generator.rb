require 'pry'

class SrtGenerator
  SPEAK_SPEED = 4 # 每秒4個字

  def self.start(src)
    replaced = src.gsub("，", "\n\n")
    splited = split(replaced)
    output = format_srt(splited)
    File.open('generated.srt', 'wb') do |file|
      file.puts(output)
    end
  end

  private

  class << self
    def split(src)
      src.split("\n\n")
    end

    def format_srt(splited)
      seq_start = 0
      splited.each_with_index.map do |seq, index|
        seq_start, clip_timecode = timecode(seq.length, seq_start)
        "#{index + 1}\n#{clip_timecode}\n#{seq}\n\n"
      end
    end

    def timecode(seq_length, start)
      # 1: "01:00:00,000 --> 01:00:07,000"
      # 2: "01:00:07,000 --> 01:00:14,000"
      clip_length = (seq_length / SPEAK_SPEED.to_f)
      close = start + clip_length
      return [close, "#{length2code(start)} --> #{length2code(close)}"]
    end

    def length2code(time_length)
      secs = time_length % 60
      mins = time_length / 60
      hours = mins / 60
      "%.2d:%.2d:%.2d,000" % [hours, mins, secs]
    end
  end
end


src = File.open($ARGV[0], 'r').read
SrtGenerator.start(src)
