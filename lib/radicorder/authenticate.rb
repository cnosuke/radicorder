require 'uri'
require 'net/https'
require 'tempfile'
require 'base64'

module Radicorder
  class Authenticater
    class << self
      def header
        @@header ||= { 
          "pragma" => "no-cache",
          "X-Radiko-App" => "pc_1",
          "X-Radiko-App-Version" => "2.0.1",
          "X-Radiko-User" => "test-stream",
          "X-Radiko-Device" => "pc"
        }
      end

      def auth1_body
        @@auth1_body ||= auth1_fms(header)
      end

      def auth_token
        @@auth_token ||= auth1_body["X-Radiko-AuthToken"] || auth1_body["X-Radiko-AuthToken".upcase] 
      end

      def auth_key_length
        @@auth_key_length ||= auth1_body["X-Radiko-KeyLength"].to_i
      end

      def auth_key_offset
        @@auth_key_offset ||= auth1_body["X-Radiko-KeyOffset"].to_i
      end


      def authenticate!(player_file_path, authkey_file_path)
        @@authkey_file_path = authkey_file_path
        get_player_file(player_file_path)
        swfextract(player_file_path, @@authkey_file_path)

        { area_code: area_code, auth_token: auth_token }
      end

      def partial_key
        return @@partial_key if defined?(@@partial_key)
        range = auth_key_offset...(auth_key_offset+auth_key_length)
        open(@@authkey_file_path,'rb') do |io|
          @@partial_key = Base64.encode64( io.read[range] ).chomp
        end
        @@partial_key
      end

      def get_player_file(player_file_path, player_url = Radicorder::PLAYER_URL)
        player_uri = URI.parse(player_url)
        https = Net::HTTP.new(player_uri.host, player_uri.port)
        https.start {
          response = https.get(player_uri.path)
          open(player_file_path, "wb") do |file|
            file.write(response.body)
          end
        }
      end

      def auth1_fms(header)
        request(Radicorder::AUTH1_FMS_URL, header).
          body.
          split(/\r\n/).
          map{ |e| e.split(/\=/) }[0..-3].
          to_h
      end

      def auth2_fms
        header.merge!(
          { "X-Radiko-Authtoken" => auth_token,
            "X-Radiko-Partialkey" => partial_key })
        request(Radicorder::AUTH2_FMS_URL, header)
      end

      def auth2_response
        @@auth2_response ||= auth2_fms
      end

      def area_code
        @@area_code ||= auth2_response.body.gsub(/\r\n/,'').split(/\,/).first
      end

      def swfextract(player_file_path, authkey_file_path)
        system(
          "#{Radicorder::SWFEXTRACT_PATH} -b 14 #{player_file_path} -o #{authkey_file_path}"
          )
      end

      def request(url, header)
        uri = URI.parse(url)
        https = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          https.use_ssl = true
          https.verify_mode = OpenSSL::SSL::VERIFY_NONE
          https.verify_depth = 5
        end

        https.start do
          response = https.post(uri.path, "\r\n", header)
          return response
        end
      end
    end
  end
end
