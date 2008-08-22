
load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'expiration-date'

task :default => 'spec:specdoc'

PROJ.name = 'expiration-date'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/directory_watcher'
PROJ.rubyforge.name = 'codeforpeople'
PROJ.rdoc.remote_dir = 'expiration-date'

PROJ.version = ExpirationDate::VERSION

PROJ.spec.opts << '--color'

# EOF
