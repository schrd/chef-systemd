#
# Cookbook Name:: systemd
# Attributes:: vconsole
#
# Copyright 2015 The Authors
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

# Ref: http://www.freedesktop.org/software/systemd/man/vconsole.conf.html
default['systemd']['vconsole'].tap do |v|
  v['KEYMAP'] = 'us'
  v['KEYMAP_TOGGLE'] = nil
  v['FONT'] = 'latarcyrheb-sun16'
  v['FONT_MAP'] = nil
  v['FONT_UNIMAP'] = nil
end
