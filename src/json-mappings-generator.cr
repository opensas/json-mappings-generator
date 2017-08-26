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

require "json"

require "./json-mappings-generator/*"

module JSON::Mappings
  DEFAULT_ROOT_NAME = "Root"
  DEFAULT_TEMPLATE  = <<-TEMPLATE
    class %{class}
      JSON.mapping(
    %{props}
      )
    end


    TEMPLATE

  # Parses a JSON document as a `JSON::Any`.
  def self.from_json(json = "", root_name = DEFAULT_ROOT_NAME, template = DEFAULT_TEMPLATE) : String
    Generator.new(json, root_name, template).from_json
  end

  private class Generator
    def initialize(@json : String = "", @root_name = DEFAULT_ROOT_NAME, @template = DEFAULT_TEMPLATE)
      @types = [] of String
    end

    def from_json : String
      parsed : JSON::Type = JSON.parse(@json).raw
      map_prop(parsed, @root_name)
      @types.join.rstrip
    end

    def map_prop(json : JSON::Type, type_name : String) : String
      case json
      # Object: recursive call, add new Type to @types
      when Hash # Hash(String, JSON::Type)
        props : String = json.map { |key, value|
          map_prop(value, key).as(String)
        }.map { |x| "    " + x }.join(",\n")

        new_type =
          @template % {class: type_name.capitalize, props: props}

        @types.push new_type
        type_name + ": " + type_name.capitalize
        # Array: process first element only (for now)
      when Array # Array(JSON::Type)
        if json.size == 0
          type_name + ": " + "Array(JSON::Any)"
        else
          prop = map_prop(json[0], type_name)
          prop.sub(": ", ": Array(") + ")"
        end
        # Scalar type ( Bool | Float64 | Int64 | String | Nil)
      else
        type_name + ": " + json.class.to_s
      end
    end
  end
end
