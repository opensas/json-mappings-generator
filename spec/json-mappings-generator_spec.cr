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

  it "should reuse type previously defined with the same name and props" do
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

    mapping = <<-mapping
    class Location
      JSON.mapping(
        lat: Float64,
        lng: Float64
      )
    end

    class Home_address
      JSON.mapping(
        address: String,
        location: Location
      )
    end

    class Work_address
      JSON.mapping(
        address: String,
        location: Location
      )
    end

    class Root
      JSON.mapping(
        name: String,
        home_address: Home_address,
        work_address: Work_address
      )
    end
    mapping

    JSON::Mappings.from_json(json).should eq(mapping)
  end

  it "when strict = false it should reuse type previously defined the same name and props and different name" do
    json = <<-JSON
    {
      "name": "john",
      "home_address" : {
        "address": "Crystal Road 1234",
        "location": { "lat": 12.3, "lng": 34.5 }
      },
      "work_address" : {
        "address": "Avey Road 4321",
        "location": { "lng": 15.3, "lat": 14.5 }
      }
    }
    JSON

    mapping = <<-mapping
    class Location
      JSON.mapping(
        lat: Float64,
        lng: Float64
      )
    end

    class Home_address
      JSON.mapping(
        address: String,
        location: Location
      )
    end

    class Root
      JSON.mapping(
        name: String,
        home_address: Home_address,
        work_address: Home_address
      )
    end
    mapping

    JSON::Mappings.from_json(json: json, strict: false).should eq(mapping)
  end

  it "should prevent types with different props and same name from colliding" do
    json = <<-JSON
    {
      "name": "john",
      "home_address" : {
        "address": "Crystal Road 1234",
        "location": { "lat": 12.3, "lng": 34.5 }
      },
      "work_address" : {
        "address": "Avey Road 4321",
        "location": { "latitude": 15.3, "longitude": 14.5, "error": "+-5km" }
      }
    }
    JSON

    mapping = <<-mapping
    class Location
      JSON.mapping(
        lat: Float64,
        lng: Float64
      )
    end

    class Home_address
      JSON.mapping(
        address: String,
        location: Location
      )
    end

    class Location1
      JSON.mapping(
        latitude: Float64,
        longitude: Float64,
        error: String
      )
    end

    class Work_address
      JSON.mapping(
        address: String,
        location: Location
      )
    end

    class Root
      JSON.mapping(
        name: String,
        home_address: Home_address,
        work_address: Work_address
      )
    end
    mapping

    JSON::Mappings.from_json(json).should eq(mapping)
  end
end
