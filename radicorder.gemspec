# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'radicorder/version'

Gem::Specification.new do |spec|
  spec.name          = "radicorder"
  spec.version       = Radicorder::VERSION
  spec.authors       = ["cnosuke"]
  spec.email         = ["cnosuke@gmail.com"]
  spec.summary       = "Radiko recording script"
  spec.description   = "Radiko recording script written with Ruby. This script can authenticate radiko server and kick rtmpdump to dump radiko streaming data using RTMP. This scripts depends on swfextract for authenticate by swf-file and rtmpdump for dumping stream data."
  spec.homepage      = "https://github.com/cnosuke/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', "~> 0.1"

  spec.add_development_dependency "bundler", "~> 1.5"
end
