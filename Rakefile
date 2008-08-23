
load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'expiration-date'

task :default => 'spec:specdoc'

PROJ.name = 'expiration-date'
PROJ.summary = 'auto-expiring / auto-refreshing attributes for your ruby classes'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/expiration-date'
PROJ.rubyforge.name = 'codeforpeople'
PROJ.rdoc.remote_dir = 'expiration-date'
PROJ.version = ExpirationDate::VERSION
PROJ.release_name = 'Buggy Bacon'

PROJ.spec.opts << '--color'

PROJ.ann.email[:server] = 'smtp.gmail.com'
PROJ.ann.email[:port] = 587
PROJ.ann.paragraphs << 'synopsis'

# EOF
