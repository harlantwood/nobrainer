<% module_namespacing do -%>
class <%= class_name %><%= " < #{options[:parent].classify}" if options[:parent] %>
<% unless options[:parent] -%>
  include NoBrainer::Document
  include NoBrainer::Document::Timestamps

<% end -%>
<% attributes.reject(&:reference?).each do |attribute| -%>
  field :<%= attribute.name -%>
<%= ", :type => #{attribute.type.to_s.classify}" if attribute.type != :object -%>
<%= ", :index => true" if attribute.has_index? %>
<% end -%>
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name -%>
<%= ", :index => true" if attribute.has_index? %>
<% end -%>
end
<% end -%>
