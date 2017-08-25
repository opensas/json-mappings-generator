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

  class Generator

    property json, root_name, template
    getter types

    def initialize()
      @json = ""
      @types = [] of String
      @root_name = "Root"
      @template = <<-TEMPLATE
        class %s
          JSON.mapping(
        %s
          )
        end


        TEMPLATE
    end

    def generate(json = "", root_name = "") : String
      @json = json if !json.empty?
      @root_name = root_name if !root_name.empty?
      @types = [] of String
      parsed = JSON.parse(@json)
      map_prop(parsed, @root_name)
      @types.join.rstrip
    end

    def map_prop(json : JSON::Any, type_name : String) : String
      # found an object (Hash), recursive call
      if json.raw.is_a?(Hash)
        props = json.as_h.map {|k, v|
          map_prop(json[k], k).as(String)
          }.map {|x| "    " + x}.join(",\n")
        new_type = @template % [type_name.capitalize, props]
        @types.push new_type
        type_name + ": " + type_name.capitalize
      elsif json.raw.is_a?(Array)
        if json.size == 0
          type_name + ": " + "Array(JSON::Type)"
        else
            prop = map_prop(json[0], type_name)
            prop.sub(": ", ": Array(") + ")"
        end
      else
        type_name + ": " + json.raw.class.to_s
      end
    end
  end

end
