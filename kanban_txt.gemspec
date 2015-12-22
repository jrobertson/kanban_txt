Gem::Specification.new do |s|
  s.name = 'kanban_txt'
  s.version = '0.1.3'
  s.summary = 'Creates a kanban.txt template file'
  s.authors = ['James Robertson']
  s.files = Dir['lib/kanban_txt.rb']
  s.add_runtime_dependency('dynarex', '~> 1.6', '>=1.6.1')
  s.signing_key = '../privatekeys/kanban_txt.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/kanban_txt'
end
