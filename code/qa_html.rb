require 'Nokogiri'
require 'open-uri'
require 'openssl'
require 'pry'




def test(domain) 

	old_sitemap_path = "http://www.#{domain}.com/pagesitemap.xml"
	new_sitemap_path = "http://#{domain}.televox.west.com/sitemap.xml"
	
	old_sitemap = Nokogiri::HTML(open(old_sitemap_path))
	new_sitemap = Nokogiri::HTML(open(new_sitemap_path))

	old_sitemap.xpath("//loc").map do |loc|
		Thread.new do

			next if !loc.text.start_with?("http://")
			next if loc.text.include?("thank-you") or loc.text.include?("unsubscribe")
			relative = to_relative(loc.text)

			old_page_path="http://www.#{domain}.com#{relative}"
			new_page_path="http://#{domain}.televox.west.com#{relative}"

			
			test_pages(new_page_path, old_page_path, relative, domain)
			
		end
	end.each{ |t| t.join}

	puts "<---------------------BLOGS------------------------>"

	test_blogs(new_sitemap, old_sitemap, domain)
end


def test_other(old_url, domain)
	old_sitemap_path = "#{old_url}/pagesitemap.xml"
	new_sitemap_path = "http://#{domain}.televox.west.com/sitemap.xml"
	
	old_sitemap = Nokogiri::HTML(open(old_sitemap_path))
	new_sitemap = Nokogiri::HTML(open(new_sitemap_path))

	old_sitemap.xpath("//loc").map do |loc|
		Thread.new do

			next if !loc.text.start_with?("http://")
			next if loc.text.include?("thank-you") or loc.text.include?("unsubscribe")
			relative = to_relative(loc.text)

			old_page_path="#{old_url}#{relative}"
			new_page_path="http://#{domain}.televox.west.com#{relative}"

			
			test_pages(new_page_path, old_page_path, relative, domain)
			
		end
	end.each{ |t| t.join}

	puts "<---------------------BLOGS------------------------>"

	test_blogs(new_sitemap, old_sitemap, domain)

end






def test_blogs_separately(new_blog_path, old_blog_path, domain)

	new_blog_page = Nokogiri::HTML(open(new_blog_path))
	old_blog_page = Nokogiri::HTML(open(old_blog_path))

	new_blogs = new_blog_page.xpath("//div[@class = 'content']//a[not(@title = 'Read More') and @href]")
	old_blogs = old_blog_page.xpath("//div[@id='content']//div[@class='right']//ul[@class='content-list']//a[not(contains(@href, 'comments')) and not(./img) and @href]")

	if new_blogs.size != old_blogs.size
		puts "new blogs: #{new_blogs}"
		puts "old blogs: #{old_blogs}"
		puts "NUMBER OF BLOGS DO NOT MATCH"
		return
	end

	test_blog_titles(new_blogs, old_blogs)

	test_blog_summary(new_blog_page, old_blog_page)

	test_blog_posts(new_blogs, old_blogs, domain)
end



# -----------------------------Regular Pages---------------------------------





def test_pages(new_page_path, old_page_path, relative, domain)

	if relative.include?("blog") or relative.include?("home") 
		return
	end

	if new_page_path.start_with?("https://")
		return
	end

	tries = 3
	begin
	  old_page = Nokogiri::HTML(open(old_page_path, redirect: false))
	rescue OpenURI::HTTPRedirect => redirect
	  return unless URI(old_page_path).host == redirect.uri.host   
	  old_page_path = redirect.uri # assigned from the "Location" response header
	  puts old_page_path
	  retry if (tries -= 1) > 0
	  raise
	end

	tries = 3
	begin
	  new_page = Nokogiri::HTML(open(new_page_path, redirect: false))
	rescue OpenURI::HTTPRedirect => redirect
	  return unless URI(new_page_path).host == redirect.uri.host   
	  new_page_path = redirect.uri # assigned from the "Location" response header
	  #puts new_page_path
	  retry if (tries -= 1) > 0
	  raise
	rescue OpenURI::HTTPError => ex
		puts relative
		puts "NO MATCHING PAGE FOUND \n"
		return
	end

	puts relative
	test_images(new_page, old_page)
	test_links(new_page, old_page, domain)



end



# -----------------------------Blog Pages---------------------------------






def test_blogs(new_sitemap, old_sitemap, domain)
	new_blog_path = new_sitemap.xpath("//loc[('blog' = substring(., string-length(.)- string-length('blog') +1))]")

	old_blog_path = old_sitemap.xpath("//loc[('blog' = substring(., string-length(.)- string-length('blog') +1))]")


	puts "#{new_blog_path}"
	puts "#{old_blog_path}"

	if old_blog_path.size == 0
		puts "No Blog Page Detected"
		return
	end
	if old_blog_path.size > 1
		puts "Blog Page Unable to be Verified"
		return
	end
	if old_blog_path.size == 1
		puts "Blog Page Detected"
		puts old_blog_path.text
	end

	if new_blog_path.size == 0
		puts "No Blog Page Detected"
		return
	end
	if new_blog_path.size > 1
		puts "Blog Page Unable to be Verified"
		return
	end
	if new_blog_path.size == 1
		puts "Blog Page Detected"
		puts new_blog_path.text
	end

	new_blog_page = Nokogiri::HTML(open(new_blog_path.text))
	old_blog_page = Nokogiri::HTML(open(old_blog_path.text))

	new_blogs = new_blog_page.xpath("//div[@class = 'content']//a[not(@title = 'Read More') and @href]")
	old_blogs = old_blog_page.xpath("//div[@id='content']//div[@class='right']//ul[@class='content-list']//a[not(contains(@href, 'comments')) and not(./img) and @href]")

	if new_blogs.size != old_blogs.size
		puts "new blogs: #{new_blogs}"
		puts "old blogs: #{old_blogs}"
		puts "NUMBER OF BLOGS DO NOT MATCH"
		return
	end

	test_blog_titles(new_blogs, old_blogs)

	test_blog_summary(new_blog_page, old_blog_page)

	test_blog_posts(new_blogs, old_blogs, domain)
 
end
	



# -----------------------------Blogs---------------------------------






def test_blog_titles(new_blogs, old_blogs)

	x = 0
	old_blogs.each do |a|

		if normalize(a.text) != normalize(new_blogs[x].text)
			puts "BLOG TITLE DOES NOT MATCH"
			puts "old blog: #{normalize(a.text)}"
			puts "new blog: #{normalize(new_blogs[x].text)}"
			
		end
		x+=1

	end

end

def test_blog_summary(new_blog_page, old_blog_page)
	new_blog_summary = new_blog_page.xpath("//div[@class='right']//div[@class='summary' and text()]")
	old_blog_summary = old_blog_page.xpath("//div[@class='right']//div[@class='left']//p[not(@class)]")

	x = 0
	if new_blog_summary.size != old_blog_summary.size
		puts "NUMBER OF SUMMARIES DOES NOT MATCH"
	end
	new_blog_summary.each do |div|
	 
		if normalize(div.text) != normalize(old_blog_summary[x].text)
			puts "BLOG SUMMARY DOES NOT MATCH"
			puts "old blog: #{normalize old_blog_summary[x].text}"
			puts "new blog: #{normalize div.text}"

		end
		x+=1

	end

end

def test_blog_posts(new_blogs, old_blogs, domain)

	x=0
	new_blogs.map do |a|
		#Thread.new do
			new_page = Nokogiri::HTML(open("http://#{domain}.televox.west.com#{a['href']}"))
			old_page = Nokogiri::HTML(open(old_blogs[x]['href']))

			puts a.text

			header = new_page.xpath("//div[@class='right']//header")
			if header.size > 0
				puts "CHECK HEADER"
			end


			test_blog_images(new_page, old_page)
			test_blog_links(new_page, old_page, domain)

			x+=1
		end
	#end.each { |t| t.join }
end




def test_blog_images(new_page, old_page)


	slideshow = new_page.xpath("//div[@class='photoGallery']")
	if slideshow.size > 0
		return
	end

	new_images = new_page.xpath("//div[@class='right']//img[not(@id='featured_image')]")
	old_images = old_page.xpath("//article//img")

	if new_images.size != old_images.size
		puts "NUMBER OF IMAGES DOES NOT MATCH"
		puts "old images: #{old_images}"
		puts "new images: #{new_images}"
		puts "number of old images: #{old_images.size}"
		puts "number of new images: #{new_images.size}"
		return
	end

	bad = 0
	x=0
	old_images.each do |img|
	
		if img['class'] != new_images[x]['class']
			if bad == 0
				puts "IMAGES WITH WRONG CLASS"
			end
			puts "new site: src=#{new_images[x]['src']}"
			bad += 1
		end
		x+=1
	end


	bad_images = new_page.xpath("//div[@class='right']//img[(@alt='' or not(@alt)) and  not(@id='featured_image') and not(starts-with(@src, 'data'))]")
	if bad_images.size > 0
		puts "  \n IMAGES WITH MISSING ALT TEXT"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with no alt text: #{bad_images.size}"
	end


	bad_images = new_page.xpath("//div[@class='right']//img[not(starts-with(@src,'/common/')) and not(starts-with(@src,'/UserFiles/')) and not(starts-with(@src,'http://www.deardoctor.com')) and not(starts-with(@src, 'data'))]" )
	if bad_images.size > 0
		puts " \n IMAGES NOT LOCALLY STORED"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images not locally stored: #{bad_images.size}"
	end

	bad_images = new_page.xpath("//div[@class='right']//img[@imagesiteid]")
	if bad_images.size > 0
		puts " \n IMAGES WITH IMAGESITEID"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with imagesiteid: #{bad_images.size}"
	end

	bad_images = new_page.xpath("//div[@class='right']//img[@objectid]")
	if bad_images.size > 0
		puts " \n IMAGES WITH OBJECTID"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with objectid: #{bad_images.size} \n \n"
	end 


end








def test_blog_links(new_page, old_page, domain)

	new_links = new_page.xpath("//div[@class='right']//a[@href]")
	old_links = old_page.xpath("//article//a[@href and not(@class='previous') and not(@href='#comments')]")
	
	if new_links.size != old_links.size
		puts "NUMBER OF LINKS DOES NOT MATCH"
		puts "new links: #{new_links}"
		puts "old links: #{old_links}"
		puts "number of old links: #{old_links.size}"
		puts "number of new links: #{new_links.size}"
		return

	end

	if new_links.size == 0 or old_links.size == 0
		return
	end

	bad_links = 0
	new_links.each do |a|
		if a['href'].start_with?("http://www.#{domain}.com")
			if bad_links == 0
				puts "LINKS THAT GO BACK TO OLD SITE"
			end
			puts "href=#{a['href']}"
			bad_links += 1
		end
	end

	z = 0
	bad_links = 0
	new_links.each do |a|
		if old_links[z]['href'].start_with?("http://www.#{domain}") or old_links[z]['href'].start_with?("https://#{domain}")
			old = to_relative(old_links[z]['href'])
		else
			old = old_links[z]['href']
		end
		if old != a['href'] and not(a['href'].start_with?("/common"))
			if bad_links == 0
				puts "LINKS THAT DO NOT MATCH"
			end
			puts "new site: href=#{a['href']}"
			puts "old site: href=#{old}"
			bad_links += 1
		end
		z += 1
	end
  
end








# -----------------------------Images---------------------------------






def test_images(new_page, old_page)


	slideshow = new_page.xpath("//div[@class='photoGallery']")
	if slideshow.size > 0
		return
	end

	new_images = new_page.xpath("//div[@class='right']//img")
	old_images = old_page.xpath("//div[@class='iapps-container']//img")

	if old_images.size == 0 and new_images.size != 0
		old_images = old_page.xpath("//div[@id='content']//img")
	end

	if new_images.size != old_images.size
		puts "NUMBER OF IMAGES DOES NOT MATCH"
		puts "number of old images: #{old_images.size}"
		puts "number of new images: #{new_images.size}"
		return
	end

	bad = 0
	x=0
	old_images.each do |img|
	
		if img['class'] != new_images[x]['class']
			if bad == 0
				puts "IMAGES WITH WRONG CLASS"
			end
			
			puts "old site: src=#{new_images[x]['src']}"
			bad += 1
		end
		x+=1
	end


	bad_images = new_page.xpath("//div[@class='right']//img[(@alt='' or not(@alt)) and not(starts-with(@src, 'data'))]")
	if bad_images.size > 0
		puts "  \n IMAGES WITH MISSING ALT TEXT"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with no alt text: #{bad_images.size}"
	end


	bad_images = new_page.xpath("//div[@class='right']//img[not(starts-with(@src,'/common/')) and not(starts-with(@src,'/UserFiles/')) and not(starts-with(@src,'http://www.deardoctor.com')) and not(starts-with(@src, 'data'))]" )
	if bad_images.size > 0
		puts " \n IMAGES NOT LOCALLY STORED"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images not locally stored: #{bad_images.size}"
	end

	bad_images = new_page.xpath("//div[@class='right']//img[@imagesiteid]")
	if bad_images.size > 0
		puts " \n IMAGES WITH IMAGESITEID"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with imagesiteid: #{bad_images.size}"
	end

	bad_images = new_page.xpath("//div[@class='right']//img[@objectid]")
	if bad_images.size > 0
		puts " \n IMAGES WITH OBJECTID"
		bad_images.each do |img|
			puts "src=#{img['src']}"
		end
		puts "Number of images with objectid: #{bad_images.size} \n \n"
	end 


end




# ------------------------Hyperlinks--------------------------------






def test_links(new_page, old_page, domain)

	new_links = new_page.xpath("//div[@class='right']//a[@href and not(@href='#aftermap' or @href='#!')]")
	old_links = old_page.xpath("//div[@class='iapps-container']//a[@href]")

	if new_links != 0 and old_links == 0
		old_links = old_page.xpath("//div[@class='overview']//a[@href]")
	end
	
	if new_links.size != old_links.size
		puts "NUMBER OF LINKS DOES NOT MATCH"
		puts "number of old links: #{old_links.size}"
		puts "number of new links: #{new_links.size}"
		return

	end

	if new_links.size == 0 or old_links.size == 0
		return
	end

	bad_links = 0
	new_links.each do |a|
		if a['href'].start_with?("http://www.#{domain}.com")
			if bad_links == 0
				puts "LINKS THAT GO BACK TO OLD SITE"
			end
			puts "href=#{a['href']}"
			bad_links += 1
		end
	end

	z = 0
	bad_links = 0
	new_links.each do |a|
		if old_links[z]['href'].start_with?("http://www.#{domain}") or old_links[z]['href'].start_with?("https://#{domain}")
			old = to_relative(old_links[z]['href'])
		else
			old = old_links[z]['href']
		end
		if old != a['href'] and not(a['href'].start_with?("/common"))
			if bad_links == 0
				puts "LINKS THAT DO NOT MATCH"
			end
			puts "new site: href=#{a['href']}"
			puts "old site: href=#{old}"
			bad_links += 1
		end
		z += 1
	end
  
end








# -----------------------------Helper Functions---------------------------------





def normalize(str)
	str.gsub(/[^A-Za-z0-9 ]*/, '')
end



def to_relative(href)

  return URI(URI.encode(href)).path

end




OpenSSL::SSL.send(:remove_const, :VERIFY_PEER)
OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
