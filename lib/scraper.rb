require 'nokogiri'
require 'open-uri'
require 'pry'

class Scraper
  def self.scrape_index_page(index_url)
    html = File.read(index_url)
    scrape = Nokogiri::HTML(html)

    scrape.css(".roster-cards-container").css("a").map do |element|
        {:name => element.children.css("h4").text,
         :location =>  element.children.css("p").text,
         :profile_url => element["href"]}
    end
  end

  def self.scrape_profile_page(profile_url)
    html = File.read(profile_url)
    scrape = Nokogiri::HTML(html)

    hash = {}
    array = ["linkedin", "github", "twitter"]

    scrape.css(".social-icon-container a").each do |element|
      if !element["href"].nil?
        symbol = array.select {|thing| element["href"].include?(thing)}
          if symbol != []
            hash.store(symbol[0].to_sym, element["href"])
          else
            hash.store(:blog, element["href"])
          end
      end
    end
    hash.merge!({:profile_quote => scrape.css(".profile-quote").text,
      :bio => scrape.css(".description-holder p").text})
    hash
  end
end
