require "radicorder/version"
require "radicorder/authenticate"
require "radicorder/recorder"

unless RUBY_VERSION > '2.1'
  puts 'Use RUBY_VERSION > 2.1'
  exit 1
end

module Radicorder
  PLAYER_URL = 'http://radiko.jp/player/swf/player_3.0.0.01.swf'
  SWFEXTRACT_PATH = '/usr/bin/swfextract'
  AUTH1_FMS_URL = 'https://radiko.jp/v2/api/auth1_fms'
  AUTH2_FMS_URL = 'https://radiko.jp/v2/api/auth2_fms'
  RTMPDUMP_PATH = '/usr/bin/rtmpdump'
  RTMP_STREAM_URL = 'rtmpe://w-radiko.smartstream.ne.jp'
  AVCONV_PATH = '/usr/bin/avconv'
  AVCONV_OPT = '-acodec libmp3lame -ab 64k -ac 1 -ar 44100'
end
