Gem::Specification.new do |spec|
  spec.name          = "bitthumb_ruby"
  spec.version       = "0.1.0"
  spec.summary       = "Ruby wrapper for Bithumb API"
  spec.authors       = ["Na, Eui-Taik"]
  spec.email         = ["damulhan@gmail.com"]
  spec.files         = Dir["lib/**/*"]
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "faye-websocket"
  spec.add_runtime_dependency "eventmachine"
end