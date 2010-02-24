lib = File.dirname(__FILE__)

require 'rubygems'
require 'active_support'
require 'active_record'
require 'time'

CONFIG          = HashWithIndifferentAccess.new YAML.load_file(File.join(lib,'..','config','punchclock.yml'))
DATABASE_CONFIG = YAML.load_file(File.join(lib,'..','config','database.yml'))

DATE_FORMAT = CONFIG[:date_format]
TIME_FORMAT = CONFIG[:time_format]
DATETIME_FORMAT = "#{DATE_FORMAT} #{TIME_FORMAT}"

# Require overrides
require File.join(lib,'overrides','date')
require File.join(lib,'overrides','time')

# Require models
require File.join(lib,'models','time_log')
require File.join(lib,'models','in')
require File.join(lib,'models','out')
require File.join(lib,'models','category')

# Require modules
require File.join(lib,'punchclock','connection')
require File.join(lib,'punchclock','reporting')
require File.join(lib,'punchclock','time_tools')
require File.join(lib,'punchclock','base')