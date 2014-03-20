module ATDIS
  class Reference < Model
    set_field_mappings ({
      more_info_url: URI,
      comments_url:  URI
    })

    validates :more_info_url, presence_before_type_cast: {spec_section: "4.3.2"}
    validates :more_info_url, http_url: {spec_section: "4.3.2"}
  end
end
