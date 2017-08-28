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
  ROOT_NAME      = "Root"
  CLASS_TEMPLATE = <<-TEMPLATE
   class %{class}
     JSON.mapping(
   %{props}
     )
   end


   TEMPLATE
  PROP_TEMPLATE = <<-TEMPLATE
       %{name}: %{type}
   TEMPLATE

  # Parses a JSON document as a `JSON::Any`.
  def self.from_json(json = "", root_name = ROOT_NAME,
                     template = CLASS_TEMPLATE, prop_template = PROP_TEMPLATE,
                     strict = true) : String
    Generator.new(json, root_name, template, prop_template, strict).from_json
  end

  private class Generator
    alias Property = {name: String, type: String}

    def initialize(@json : String = "", @root_name = ROOT_NAME,
                   @template = CLASS_TEMPLATE, @prop_template = PROP_TEMPLATE,
                   @strict = true)
      @types = {} of String => Set(Property)
    end

    def from_json : String
      parsed : JSON::Type = JSON.parse_raw(@json)
      map_prop(parsed, @root_name)
      from_types(@types)
    end

    def from_types(types) : String
      types.map { |type, props_defs|
        props = props_defs.map { |prop|
          @prop_template % prop
        }.join(",\n")
        @template % {class: type, props: props}
      }.join.rstrip
    end

    def map_prop(json : JSON::Type, name : String) : Property
      case json
      # Object: recursive call, add new Type to @types
      when Hash # Hash(String, JSON::Type)
        props : Set(Property) = json.map { |key, value|
          map_prop(value, key).as(Property)
        }.to_set

        type_name = name.capitalize

        # the type already exists, do not create it again
        if exists?(type_name, props)
          return {name: name, type: type_name}
        end

        # if not strict mode try to reuse a type with the same props
        if !@strict && (prev_type = find_by_props?(props))
          return {name: name, type: prev_type}
        end

        # already exists a type with the same name but different props
        if @types.has_key?(type_name) && @types[type_name] != props
          new_type_name = rename_type(type_name)
          @types[new_type_name] = props
          return {name: name, type: new_type_name}
        end

        # create the new type
        if !@types.has_key?(type_name)
          @types[type_name] = props
        end

        {name: name, type: type_name}

        # Array
      when Array # Array(JSON::Type)
        # collect the type of every element in the array
        arr_types = json.map { |element|
          map_prop(element, name)[:type]
        }.to_set.join(" | ")
        # no elements in the array
        arr_types = "JSON::Any" if arr_types.empty?

        {name: name, type: "Array(#{arr_types})"}

        # Scalar type ( Bool | Float64 | Int64 | String | Nil)
      else
        {name: name, type: json.class.to_s}
      end
    end

    def exists?(type : String, props) : Bool
      @types.has_key?(type) && @types[type] == props
    end

    # Returns the name of the first type with the same properties (matching name and type of each one)
    def find_by_props?(props) : String | Nil
      type = @types.find { |key, value| value == props }
      type ? type[0] : nil
    end

    def rename_type(type) : String
      # regexp to get the last numbers of the name
      match = /(.*\D)(\d*)$/.match(type)
      match ? match[1] + (("0" + match[2]).to_i + 1).to_s : type + "_"
    end
  end
end
