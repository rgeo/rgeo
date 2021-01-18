# frozen_string_literal: true

require "rgeo"
require "nokogiri"

def classify_sym(sym)
  sym.to_s.split("_").collect(&:capitalize).join
end

def debug(*args)
  #puts *args
end

def html_rep(bool)
  if bool
    '<span style="color:#78b13f">&#10003;</span>'
  else
    '<span style="color:red">&#10007;</span>'
  end
end

def html_rep_gh(bool)
  if bool
    "✅"
  else
    "❌"
  end
end

factories = {
  geos: RGeo::Geos.factory,
  geos_zm: RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true),
  ffi: RGeo::Geos.factory(native_interface: :ffi),
  ffi_zm: RGeo::Geos.factory(has_z_coordinate: true, has_m_coordinate: true, native_interface: :ffi),
  cartesian: RGeo::Cartesian.simple_factory,
  projection: RGeo::Geographic.simple_mercator_factory,
  spherical: RGeo::Geographic.spherical_factory
}
results = {}
factories.each do |type, fac|
  results[type] = {}
  geoms = {
    point: fac.point(0, 0),
    line_string: fac.line_string([fac.point(0, 0), fac.point(1, 1), fac.point(2, 2)]),
    linear_ring: fac.linear_ring([fac.point(0, 0), fac.point(0, 1), fac.point(1, 1), fac.point(1, 0), fac.point(0, 0)]),
    polygon: fac.polygon(fac.linear_ring([fac.point(0, 0), fac.point(0, 1), fac.point(1, 1), fac.point(1, 0),
                                          fac.point(0, 0)])),
    collection: fac.collection([]),
    multi_point: fac.multi_point([fac.point(0, 0), fac.point(1, 1)]),
    multi_line_string: fac.multi_line_string([fac.line_string([fac.point(0, 0), fac.point(1, 1), fac.point(2, 2)]),
                                              fac.line_string([fac.point(3, 3), fac.point(4, 4)])]),
    multi_polygon: fac.multi_polygon([fac.polygon(fac.linear_ring([fac.point(0, 0), fac.point(0, 1), fac.point(1, 1),
                                                                   fac.point(1, 0), fac.point(0, 0)]))])
  }

  geoms.each do |g_type, geom|
    basic_methods = %i[factory dimension geometry_type srid envelope as_text as_binary is_empty? is_simple? boundary
                       convex_hull buffer]
    basic_methods.each do |meth|
      desc = "#{classify_sym(g_type)}##{meth}"
      begin
        if meth == :buffer
          geom.send(meth, 1)
        else
          geom.send(meth)
        end

        # mark true if supported
        results[type][desc] = true
      rescue RGeo::Error::UnsupportedOperation
        results[type][desc] = false
      rescue NoMethodError => e
        debug 'no method', desc.inspect, e.inspect
        results[type][desc] = false
      rescue StandardError => e
        debug 'error', e.full_message(highlight: true), desc
        results[type][desc] = false
      end
    end

    relational_methods = %i[equals? eql? disjoint? intersects? touches? crosses? within? contains? overlaps? relate?]
    relational_methods.each do |meth|
      # loop through every geometry type again because these methods must be compared against a another geometry
      geoms.each do |g_type2, geom2|
        desc = "#{classify_sym(g_type)}##{meth}(#{classify_sym(g_type2)})"
        begin
          if meth == :relate?
            geom.send(meth, geom2, 'FT*******')
          else
            geom.send(meth, geom2)
          end
          results[type][desc] = true
        rescue RGeo::Error::UnsupportedOperation => e
          results[type][desc] = false
        rescue NoMethodError => e
          p 'no method'
          p desc
          p e
          results[type][desc] = false
        rescue StandardError => e
          p 'error'
          p e
          p e.backtrace
          p desc
          results[type][desc] = false
        end
      end
    end
  end
end

ops = results.first[1].keys
facs = results.keys

html = "<table>\n"
html += "\t<tr>\n"
html += "\t\t<th></th>\n"
results.each_key do |k|
  html += "\t\t<th>#{k}</th>\n"
end
html += "\t</tr>\n"

ops.each do |op|
  html += "\t<tr>\n"
  html += "\t\t<td>#{op}</td>\n"
  facs.each do |fac|
    html += "\t\t<td>#{html_rep_gh(results[fac][op])}</td>\n"
  end
  html += "\t</tr>\n"
end

html += "</table>"

File.open("doc/Factory-compatibility.md", "r+") do |file|
  file.take_while { |line| !line.start_with?("<!-- AUTO-GENERATED") }
  file.puts html
end

debug "doc/Factory-compatibility.md edited."
