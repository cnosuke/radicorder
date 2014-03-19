module Radicorder
  class Recorder
    def initialize(rec_time, channel_id, out_flv_path, out_mp3_path, player_file_path = nil, authkey_file_path = nil)
      @rec_time = rec_time.to_i * 60 # convert from minutes to seconds
      @channel_id = channel_id
      @out_flv_path = out_flv_path
      @out_mp3_path = out_mp3_path
      @player_file_path = player_file_path ||
      Tempfile.open(['player', '.swf']).path
      @authkey_file_path = authkey_file_path ||
      Tempfile.open(['authkey', '.png']).path
    end

    def self.ready(*arg)
      self.new(*arg)
    end

    class AuthenticateError < StandardError; end

    def authenticate!
      auth = Authenticater.authenticate!(
        @player_file_path, @authkey_file_path
        )
      @area_code = auth[:area_code]
      @auth_token = auth[:auth_token]
      raise AuthenticateError unless @area_code && @auth_token
      return true
    end

    def record!
      rtmpdump(
        @rec_time,
        @channel_id,
        @out_flv_path,
        @auth_token
        )
    end

    def convert!
      avconv(@out_flv_path, @out_mp3_path)
    end

    def rtmpdump(rec_time, channel_id, out_flv_path, auth_token)
      system(
        "#{Radicorder::RTMPDUMP_PATH} -v -r '#{Radicorder::RTMP_STREAM_URL}' --playpath 'simul-stream.stream' --app '#{channel_id}/_definst_' -W #{Radicorder::PLAYER_URL} -C S:'' -C S:'' -C S:'' -C S:#{auth_token} --live --flv #{out_flv_path} -B #{rec_time}"
        )
    end

    def avconv(out_flv_path, out_mp3_path)
      system(
        "#{Radicorder::AVCONV_PATH} -i #{out_flv_path} #{AVCONV_OPT} #{out_mp3_path}"
        )
    end
  end
end
