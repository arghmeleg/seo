#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'

start = Time.now

def get_links_from_page(page, text = false)

end

def get_links_from_sitemap(sitemap)
  return sitemap.xpath("//loc")
end

def get_links_from_url(url, text = false)
  if url =~ /.xml$/i
    puts "sitemap"
    
  else
    puts "not sitemap"
  end
end

def get_all_links_from_sitemaps(url)
  puts "Fetching #{url}"
  sitemap_urls = []
  begin
    sitemap = Nokogiri::XML(open(url))
    sitemap.css("loc").each do |loc|
      this_url = loc.inner_text
      if is_xml_url? this_url
        sitemap_urls.concat get_all_links_from_sitemaps(this_url)
      else
        sitemap_urls << this_url
      end
    end
  rescue
    puts "ERROR FETCHING #{url}"
  end
  sitemap_urls
end

def get_links_from_page(page)
  links = page.css("a").map {|a| a['href'] }
  links.reject {|x| x.nil? || x.include?(";")}
end

def get_absolute_links_from_page(page, page_url)
  links = page.css("a").map {|a| a['href'] }
  links.reject! {|x| x.nil? || x.include?(";")}
  links.map {|link| get_absolute_url(page_url, link).chomp("/")}
end

def get_absolute_url(current_page, link)
  link_uri = URI(link)
  
  if !link_uri.host #relative
    current_page_uri = URI(current_page)
    url_start = "#{current_page_uri.scheme}://#{current_page_uri.host}"
    if link =~ /^\//  #root relative
      return "#{url_start}#{link_uri.path}"
    else  #directory relative
      relative_path = current_page_uri.path.split("/").reverse.drop(1).reverse.join("/")
      return "#{url_start}#{relative_path}/#{link}"
    end

  end
  
  return link
  
end

def get_absolute_internal_links_from_page(page, page_url)
  get_absolute_links_from_page(page, page_url).select {|link| link.include?(URI(page_url).host)}
end


def is_xml_url?(url)
  url =~ /(.xml)(\?.*)?$/i
end

def get_nokogiri_page
end

def get_canonical_from_page(page)
  page.css("link[rel='canonical']")[0]['href']
end

page = Nokogiri::HTML(open(ARGV[0]))

puts get_canonical_from_page(page)

#puts get_absolute_internal_links_from_page(page,ARGV[0]).uniq.join("\n")




#get_links_from_url ARGV[0]


#puts get_all_links_from_sitemaps(ARGV[0]).join("\n")

