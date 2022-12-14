FactoryBot.define do
  factory :ckan_part_status, class: Ckan::Part::Status do
    name { unique_id }
    filename { "#{name}.part.html" }
    route { "ckan/status" }
    ckan_url { "http://example.com" }
    ckan_basicauth_state { "disabled" }
    ckan_status { "dataset" }
  end
end
