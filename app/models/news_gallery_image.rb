class NewsGalleryImage < ActiveRecord::Base
  has_attached_file :photo, :styles => { :small => "75x75>", :medium => "500x500>", :thumb => "30x30>" },
                    :url => "/media/news/gallery/:attachment/:id/:style_:basename.:extension"
  
  belongs_to :news_folder
  
  validates_presence_of  :title
end
