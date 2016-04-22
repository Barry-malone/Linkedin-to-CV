require 'linkedin_scraper'
require 'prawn'
require 'prawn/table'
require 'sinatra'
require 'certified'
require "open-uri"

#set :environment, :production
#set :port, 8080

get '/' do 

erb :index

end 

get '/scraped' do 

 @spec_profile = params[:spec_profile] #This is the main form parameter to specify the profile URL.

 content_type 'application/pdf' #Sets the directory content to PDF.

 profile = Linkedin::Profile.get_profile("#{@spec_profile}") #Creates a new instance of the scraper with the user specified profile.

 @skills = profile.skills.to_s #Pulls in the skills and changes them to a STRING.

  pdf = Prawn::Document.new(:page_size => 'A4') #Creates a new PDF document A4 sized.

  pdf.font "RobotoSlab-Regular.ttf" #custom font to deal  with the requirments of UTF-8 encoding.

  pdf.text "Curriculum Vitae of  " +  profile.name, :size => 11,  :align => :center #Sets a heading at the top of the PDF and pulls in the name on the profile.
  
  pdf.stroke_horizontal_rule #Adds in a horizontal line at the top of the PDF
  
  pdf.move_down(15) #Creates a space of 15px on the PDF
  pdf.image open(profile.picture),:height => 80, :width => 80, :align => :left
  
  pdf.text "Profile Summary", :align => :center
  pdf.move_down(5)
  pdf.text profile.summary.to_s, :size => 9,  :align => :center
  pdf.move_down(10)
  pdf.text "Education", :align => :center, :underline => true
  pdf.move_down(5)
  profile.education.each do |ed| 
  
  pdf.move_down(5)
  pdf.text ed[:name] + " " + ed[:description] + " "+ ed[:start_date] + " - " + ed[:end_date], :inline=>true, :size => 9

end

pdf.move_down(15)
 pdf.text "Work Experience", :align => :center
pdf.move_down(5)
profile.current_companies.each do |workex|
  pdf.move_down(3)
  pdf.text "Current Role:" + " - "+ workex[:title] + " - " + workex[:company] + " - "  + workex[:duration] , :inline=>true, :size => 9
end 

pdf.move_down(15)
profile.past_companies.each do |pastcomp|
  pdf.move_down(3)
  pdf.text pastcomp[:title] + " - " + pastcomp[:company] + " - "  + pastcomp[:duration] , :inline=>true, :size => 9
end 

pdf.move_down(15)

  pdf.text "Key Skills" #Skills heading on PDF

  pdf.move_down(5) #Creates a space of 5px on the PDF

  profile.skills[0,6].each do |skill| #Takes the first 6 skills array and turns into a list preappended with a bullet point.
  
  pdf.text skill.prepend("• "), :inline=>true, :size => 9 #Sets all skills to be inline on PDF

   
end

   pdf.move_down(10)#Creates a space of 10px on the PDF
   pdf.bounding_box([0, pdf.bounds.bottom + 10], :width => pdf.bounds.width) {
   pdf.line_width(2)
   pdf.stroke_horizontal_rule #Adds in the horizontal line at the end of the PDF.
   pdf.move_down(5)
  }
  pdf.render #Renders the PDF as a full view.



end 