# Author:: Nathan Milford (<nathan@milford.io>)
# Copyright:: Copyright (c) 2013 Nathan Milford
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require File.dirname(__FILE__) + '/lib/ronin/version'
require File.dirname(__FILE__) + '/lib/ronin/config'
require File.dirname(__FILE__) + '/lib/ronin/util'
require 'rspec/core/rake_task'
require 'tailor/rake_task'

config_file_path = '/etc/ronin'
config_file      = "#{config_file_path}/ronin.rb"
artifacts_file   = "#{config_file_path}/artifacts.yaml"
lock_file        = "/var/tmp/ronin.lock"

task :default => "test:all"
task :test    => "test:all"

namespace :test do
  Tailor::RakeTask.new(:style) do |t|
    t.config_file = File.expand_path(".tailor")
  end

  RSpec::Core::RakeTask.new(:run_spec)

  task :spec do
    Rake::Task["spec_server:up"].execute
    Rake::Task["test:run_spec"].execute
    sh %[sleep 5 ; curl -L http://127.0.0.1:4001/v2/keys/ronin/config/common ]
    Rake::Task["spec_server:down"].execute
  end

  task :all => ["test:style", "test:spec"]

end

namespace :spec_server do
  task :up do
    puts "*** Starting fake etcd server."
    sh %{cd spec ; #{Ronin::Util.find_cmd("rackup")} config.ru -o 127.0.0.1 -p 4001 -D -P rack.pid}
  end

  task :down do
    puts "*** Starting fake etcd server."
    sh %{cd spec ; kill -KILL `cat rack.pid`; rm rack.pid}
  end
end

task :install do
  Rake::Task["build:gem"].invoke
  Rake::Task["setup"].invoke
  puts "*** Installing Ronin #{Ronin::VERSION}."
  sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("gem")} install #{File.expand_path(".")}/ronin-wrapper-#{Ronin::VERSION}.gem --no-rdoc --no-ri}
end

task :uninstall do
  sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("gem")} uninstall #{File.expand_path(".")}/ronin-wrapper-#{Ronin::VERSION}.gem}
end

task :load_config do
  Ronin::Config.from_file(config_file)
  puts "*** Loading config from #{config_file}."

  if Ronin::Config[:config_from_etcd] == true
    puts "*** Config points to etcd, loading from there."
    Ronin::Etcd.get_config.each do |k, v|
      v = v[1..-1].to_sym if v.start_with?(':')
      Ronin::Config["#{k}"] = v
    end
  end
end

task :setup do
  puts "*** Setting up directories and seeding config files."

  if File.exist?(config_file_path)
    puts "*** Directory #{config_file_path} already exists."
  else
    puts "*** Creating directory #{config_file_path}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("mkdir")} -p #{config_file_path}}
  end

  if File.exist?(config_file)
    puts "*** Configuration file #{config_file} already exists."
  else
    puts "*** Seeding sample configuration file in #{config_file}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("cp")} #{File.expand_path("conf/ronin.rb.sample")} #{config_file}}
  end

  if File.exist?(artifacts_file)
    puts "*** Artifacts file #{artifacts_file} already exists."
  else
    puts "*** Seeding sample artifacts file in #{artifacts_file}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("cp")} #{File.expand_path("conf/artifacts.yaml.sample")} #{artifacts_file}}
  end

  Rake::Task["load_config"]

  if File.exist?(Ronin::Config[:log_path])
    puts "*** Directory #{Ronin::Config[:log_path]} already exists."
  else
    puts "*** Creating directory #{Ronin::Config[:log_path]}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("mkdir")} -p #{Ronin::Config[:log_path]}}
  end

  if File.exist?(Ronin::Config[:artifact_path])
    puts "*** Directory #{Ronin::Config[:artifact_path]} already exists."
  else
    puts "*** Creating directory #{Ronin::Config[:artifact_path]}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("mkdir")} -p #{Ronin::Config[:artifact_path]}}
  end
end

namespace :build do
  task :gem do
    puts "*** Building a fresh gem at #{File.expand_path(".")}/ronin-wrapper-#{Ronin::VERSION}.gem."
    sh %{#{Ronin::Util.find_cmd("gem")} build #{File.expand_path(".")}/ronin-wrapper.gemspec}
  end

  task :rpm do
    if Ronin::Util.find_cmd("rpmbuild") and Ronin::Util.find_cmd("rpmdev-setuptree")
      unless File.exist?("#{File.expand_path('~')}/rpmbuild")
        puts "Setting up RPM build tree at ~/rpmbuild."
        sh %{#{Ronin::Util.find_cmd("rpmdev-setuptree")}}
      end
      sh %{#{Ronin::Util.find_cmd("rpmbuild")} -bb ./packaging/rpm/ronin-wrapper.spec}
    else
      puts "You must have rpmdevtools installed to build an RPM package."
      exit 1
    end
  end

  task :deb do
    puts 'not implemented'
  end
end

namespace :bundle do
  task :check do
    sh %{#{Ronin::Util.find_cmd("bundle")} check}
  end

  task :install do
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("bundle")} install}
  end
end

namespace :clean do
  task :artifacts do
    Rake::Task["load_config"]
    puts "*** Cleaning up artifacts directory at #{Ronin::Config[:artifact_path]}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("rm")} -rf #{Ronin::Config[:artifact_path]}}
  end

  task :lock do
    puts "*** Cleaning up lock file at #{lock_file}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("rm")} -f #{lock_file}}
  end

  task :gems do
    puts "*** Cleaning up gem files at #{File.expand_path(".")}."
    sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("rm")} -f #{File.expand_path(".")}/*.gem}
  end

  task :config do
    if File.exist?(config_file)
      puts "*** Removing configuration file #{config_file}."
      sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("rm")} -f #{config_file}}
    else
      puts "*** No configuration file found at #{config_file}."
    end

    if File.exist?(artifacts_file)
      puts "*** Removing artifacts file #{artifacts_file}."
      sh %{#{Ronin::Util.find_cmd("sudo")} #{Ronin::Util.find_cmd("rm")} -f #{artifacts_file}}
    else
      puts "*** No artifacts file found at #{artifacts_file}."
    end
  end

  task :all => ["clean:lock", "clean:artifacts"]
end
