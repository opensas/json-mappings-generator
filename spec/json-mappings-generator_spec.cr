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

require "./spec_helper"
require "../src/json-mappings-generator"

describe Json::Mappings::Generator do
  it "should handle nested objects" do
    json = <<-JSON
    {
      "address": "Crystal Road 1234",
      "location": { "lat": 12.3, "lng": 34.5 }
    }
    JSON

    mapping = <<-mapping
    class Location
      JSON.mapping(
        lat: Float64,
        lng: Float64
      )
    end

    class Root
      JSON.mapping(
        address: String,
        location: Location
      )
    end
    mapping

    JSON::Mappings.from_json(json).should eq(mapping)
  end

  it "should handle arrays of objects" do
    json = <<-JSON
    {
      "locations": [
        { "lat": 12.3, "lng": 34.5 },
        { "lat": 13, "lng": 35.6 }
      ]
    }
    JSON

    mapping = <<-mapping
    class Locations
      JSON.mapping(
        lat: Float64,
        lng: Float64
      )
    end

    class Root
      JSON.mapping(
        locations: Array(Locations)
      )
    end
    mapping

    JSON::Mappings.from_json(json).should eq(mapping)
  end

  it "should handle empty arrays" do
    json = <<-JSON
    {
      "address": "Crystal Road 1234",
      "names": []
    }
    JSON

    mapping = <<-mapping
    class Root
      JSON.mapping(
        address: String,
        names: Array(JSON::Any)
      )
    end
    mapping

    JSON::Mappings.from_json(json).should eq(mapping)
  end
end
