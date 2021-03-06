#
# This file is part of json-mappings-generator.
#
# Copyright (C) 2017  opensas <opensas@gmail.com>
#
# json-mappings-generator is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# json-mappings-generator is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with json-mappings-generator.  If not, see <http://www.gnu.org/licenses/>.
#

require "./json-mappings-generator"

json = <<-JSON
{
  "name": "john",
  "home_address" : {
    "address": "Crystal Road 1234",
    "location": { "lat": 12.3, "lng": 34.5 }
  },
  "work_address" : {
    "address": "Avey Road 4321",
    "location": { "lat": 15.3, "lng": 14.5 }
  }
}
JSON

puts JSON::Mappings.from_json(json)
