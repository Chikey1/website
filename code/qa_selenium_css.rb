require 'selenium-webdriver'
require 'nokogiri'
require 'pry'

$username = 'sara.qi'
$password = 'Welcome1234'

class TelevoxQA
  attr_accessor :driver_old, :driver_new, :old_domain, :new_domain

  def initialize(old_domain, new_domain)
    self.driver_old = Selenium::WebDriver.for :chrome
    self.driver_new = Selenium::WebDriver.for :chrome
    self.old_domain = old_domain
    self.new_domain = new_domain
  end
 
  def test
    File.open("Desktop/css_results.txt", "w") do |file|
      file.puts "*************************************************"
      file.puts "CURRENTLY TESTING:"
      file.puts "old site: #{old_domain}"
      file.puts "new site: #{new_domain}"
      file.puts "*************************************************"
    end

    relatives = get_relatives
   
    relatives.map do |path|
      next if path.end_with?("main") or path.end_with?("home")
      old_url = old_url_for(path)
      new_url = new_url_for(path)

      driver_old.navigate.to(old_url)
      driver_new.navigate.to(new_url)

      # add exception for 404s

      wait.until {
        driver_old.page_source.match(/<header/i) and
          driver_new.page_source.match(/<header/i)
      }

      ensure_logged_in

      page_pass = compare_css(old_url, new_url)

      if !page_pass
        puts "#{old_url} FAILED"
      else
        puts "#{old_url} PASSED"
      end
    end

    driver_old.quit
    driver_new.quit
  end

private

  def compare_css(old_url, new_url)
    page_pass = true
    tags = ["h1", "h2", "h3", "h4", "h5", "h6", "span", "p", "li", "a"]

    #if !compare_title(old_url, new_url)
   #   page_pass = false
 #   end

    tags.map do |tag|
      if !compare_element(old_url, new_url, tag)
        page_pass = false
      end
    end

    if !compare_image(old_url, new_url)
      page_pass = false
    end

    return page_pass
  end

  def compare_title(old_url, new_url)
    title_pass = true
    styles = ["font-size", "font-family", "font-color", "line-height", "font-weight"]

    if old_element_present(:xpath, "//h1")
      old_title = driver_old.find_element(:xpath, "//h1")
    end
    if new_element_present(:xpath, "//h1")
      new_title = driver_new.find_element(:xpath, "//h1")
    end

    if old_title == nil || new_title == nil
      if old_title == nil and new_title == nil
        return true
      else
        binding.pry
        return false
      end
    end

    if old_title.size != new_title.size
      binding.pry
       File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************" 
        file.puts "NUMBER OF H1 TAGS DO NOT MATCH"
        file.puts "old url: #{old_url} - #{old_title.size}"
        file.puts "new url: #{new_url} - #{new_title.size}"
        file.puts "*************************************************"
      end
      return false
    end
    old_title.size.times do |index|
      styles.each do |style|
        if old_title[index].style(style) != new_title[index].style(style)
          if style != "font-family" || (old_title[index].style(style) != new_title[index].style(style).split(",").first)
            if title_pass
              File.open("Desktop/css_results.txt", "a") do |file|
                file.puts "*************************************************" 
                file.puts "STYLE OF H1 TAG IS DIFFERENT"
                file.puts "old url: #{old_url}"
                file.puts "new url: #{new_url}"
              end
              title_pass = false
            end

            File.open("Desktop/css_results.txt", "a") do |file|
              file.puts "\nstyle error: #{style}"
              file.puts "old title: #{old_elements[index].text} - #{old_elements[index].style(style)}"
              file.puts "new title: #{new_elements[index].text} - #{new_elements[index].style(style)}"
            end
          end
        end
      end        
    end

    if !title_pass
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************"
      end
    end

    return title_pass
  end




  def compare_element(old_url, new_url, tag)
    element_pass = true
    styles = ["font-size", "font-family", "font-color", "line-height"]

    old_elements = find_old_elements(tag)
    new_elements = find_new_elements(tag)

    if (old_elements == nil) || (new_elements == nil)
      if (old_elements == nil) and (new_elements == nil)
        return true
      else
        binding.pry
        File.open("Desktop/css_results.txt", "a") do |file|
          file.puts "*************************************************" 
          file.puts "NUMBER OF ELEMENTS DO NOT MATCH"
          file.puts "old url: #{old_url} - <#{tag}>"
          file.puts "new url: #{new_url} - <#{tag}>"
          file.puts "*************************************************"
        end
        return false
      end
    end
   
    if old_elements.size != new_elements.size
      binding.pry
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************" 
        file.puts "NUMBER OF ELEMENTS DO NOT MATCH"
        file.puts "old url: #{old_url} - #{old_elements.size} <#{tag}>"
        file.puts "new url: #{new_url} - #{new_elements.size} <#{tag}>"
        file.puts "*************************************************"
      end
      return false
    end

    old_elements.size.times do |index|
      styles.each do |style|
        puts "old element: #{old_elements[index].style(style)} \t new element: #{new_elements[index].style(style)}"
        if old_elements[index].style(style) != new_elements[index].style(style)
          if style != "font-family" || old_elements[index].style(style) != new_elements[index].style(style).split(",").first
            if element_pass
              File.open("Desktop/css_results.txt", "a") do |file|
                file.puts "*************************************************" 
                file.puts "STYLE OF ELEMENT IS DIFFERENT"
                file.puts "old url: #{old_url}"
                file.puts "new url: #{new_url}"
              end
              element_pass = false
            end

            File.open("Desktop/css_results.txt", "a") do |file|
              file.puts "\nstyle error: #{style}"
              file.puts "element: #{tag}"
              file.puts "old element: #{old_elements[index].text} - #{old_elements[index].style(style)}"
              file.puts "new element: #{new_elements[index].text} - #{new_elements[index].style(style)}"
            end
          end
        end
      end        
    end

    if !element_pass
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************"
      end
    end

    return element_pass
  end

  def compare_image(old_url, new_url)
    image_pass = true
    old_images = find_old_elements("img")
    new_images = find_new_elements("img")

   if (old_images == nil) || (new_images == nil)
    if (old_images == nil) and (new_images == nil)
      return true
    else
      binding.pry
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************" 
        file.puts "NUMBER OF IMAGES DO NOT MATCH"
        file.puts "old url: #{old_url}"
        file.puts "new url: #{new_url}"
        file.puts "*************************************************"
      end
      return false
    end
  end


    if old_images.size != new_images.size
      binding.pry
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************" 
        file.puts "NUMBER OF IMAGES DO NOT MATCH"
        file.puts "old url: #{old_url} - #{old_images.size} images"
        file.puts "new url: #{new_url} - #{new_images.size} images"
        file.puts "*************************************************"
      end
      return false
    else
      old_images.size.times do |index|
        if old_images[index].size != new_images[index].size
          if image_pass
            File.open("Desktop/css_results.txt", "a") do |file|
              file.puts "*************************************************" 
              file.puts "SIZE OF IMAGE IS DIFFERENT"
              file.puts "old url: #{old_url}"
              file.puts "new url: #{new_url}"
            end
            image_pass = false
          end
          File.open("Desktop/css_results.txt", "a") do |file|
            file.puts "old image: #{old_images[index].attribute('src')} - #{old_images[index].size}"
            file.puts "new image: #{new_images[index].attribute('src')} - #{new_images[index].size}"
          end
        end
      end
    end
    if !image_pass
      File.open("Desktop/css_results.txt", "a") do |file|
        file.puts "*************************************************"
      end
    end

    return image_pass
  end

  def find_old_elements(tag)
    if !old_element_present(:xpath, "//div[@id='content']//#{tag}")
      return nil
    end

    old_elements = driver_old.find_elements(:xpath, "//div[@id='content']//#{tag}")

    container_path = ["//div[@id='content']//nav","//div[@class='CLFormContainer']","//div[@class='map']"]
    empty = true
    bad_old_elements = nil

    container_path.each do |path|
      if old_element_present(:xpath, "#{path}//#{tag}")
        if empty
          bad_old_elements = driver_old.find_elements(:xpath, "#{path}//#{tag}")
          empty = false
        else
          bad_old_elements += driver_old.find_elements(:xpath, "#{path}//#{tag}")
        end
      end
    end
  
    if bad_old_elements != nil
      bad_old_elements.each do |el|
        old_elements.delete(el)
      end
    end

    if old_elements.size == 0
      return nil
    else
      return old_elements
    end   
  end

  def find_new_elements(tag)
    if !new_element_present(:xpath, "//div[@id='content']//#{tag}")
      return nil
    end

    new_elements = driver_new.find_elements(:xpath, "//div[@id='content']//#{tag}")

    container_path = ["//div[@id='content']//nav","//div[@class='secureform']","//div[contains(@id,'map')]",
                        "//div[@class='offScreen']","//div[@class='photoGallery']"]
    empty = true
    bad_new_elements = nil

    container_path.each do |path|
      if new_element_present(:xpath, "#{path}//#{tag}")
        if empty
          bad_new_elements = driver_new.find_elements(:xpath, "#{path}//#{tag}")
          empty = false
        else
          bad_new_elements += driver_new.find_elements(:xpath, "#{path}//#{tag}")
        end
      end
    end

    if bad_new_elements != nil
      bad_new_elements.each do |el|
        new_elements.delete(el)
      end
    end

    if new_elements.size == 0
      return nil
    else
      return new_elements
    end
  end


  def get_relatives
    driver_old.navigate.to(old_url_for("pagesitemap.xml"))
    wait.until {
      driver_old.page_source.match(/<loc>/i)
    }

    relatives = Nokogiri::HTML(driver_old.page_source).xpath("//loc")
    return relatives.map do |loc|
      loc = loc.text
      loc.slice!(old_domain)
      loc
    end
  end

  def ensure_logged_in
    if new_element_present(:id, "ctl00_ContentPlaceHolder1_txtPassword")
      driver_new.find_element(:id, 'ctl00_ContentPlaceHolder1_txtUsername')
        .send_keys($username)
      driver_new.find_element(:id, 'ctl00_ContentPlaceHolder1_txtPassword')
        .send_keys($password)
      driver_new.find_element(:id, 'ctl00_ContentPlaceHolder1_btnLogin').click

      wait.until {
        driver_new.page_source.match(/<header/i)
      }    
    end
  end

  def old_element_present(how, what)
    @driver_old.manage.timeouts.implicit_wait = 0
    result = @driver_old.find_elements(how, what).size() > 0
    @driver_old.manage.timeouts.implicit_wait = 3
    return result
  end


  def new_element_present(how, what)
    @driver_new.manage.timeouts.implicit_wait = 0
    result = @driver_new.find_elements(how, what).size() > 0
    @driver_new.manage.timeouts.implicit_wait = 3
    return result
  end

  def wait
    Selenium::WebDriver::Wait.new(:timeout => 30)
  end

  def old_url_for(path)
    URI.join(old_domain, path).to_s
  end

  def new_url_for(path)
    URI.join(new_domain, path).to_s
  end

end
