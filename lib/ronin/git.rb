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
require "mixlib/shellout"
require 'ronin/config'

module Ronin
  module Git
    def branch(mod)
      @cmd = Mixlib::ShellOut.new("git --git-dir=#{Ronin::Config[:module_path]}/#{mod}/.git --work-tree=#{Ronin::Config[:module_path]}/#{mod}/ branch")
      @cmd.run_command
      @branch = @cmd.stdout.chomp.split(' ')[1]
      @branch
    end
    module_function :branch

    def pull_and_report_updated(mod)
      @cmd = Mixlib::ShellOut.new("git --git-dir=#{Ronin::Config[:module_path]}/#{mod}/.git --work-tree=#{Ronin::Config[:module_path]}/#{mod}/ pull")
      @cmd.run_command
      @updated = @cmd.stdout.include?("Updating")
      @updated ? true : false
    end
    module_function :pull_and_report_updated

    def clone(mod, branch)
      @cmd = Mixlib::ShellOut.new("git clone #{Ronin::Config[:git_url]}/#{mod}/ #{Ronin::Config[:module_path]}/#{mod}/ -b #{branch}")
      @cmd.run_command
      puts @cmd.stdout
    end
    module_function :clone
  end
end