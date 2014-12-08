module Sluggable
  extend ActiveSupport::Concern

  included do 
    before_save :generate_slug!
    class_attribute :slug_column
  end

  def to_param
      slug
  end

  def create_slug(fulltext)
      slug = fulltext.downcase.strip.gsub(/[^\w-]/, "-").gsub(/-+/, "-")
    end

  def append_suffix(str, count)
    if str.split('-').last.to_i != 0
      str = str.split('-').slice(0..-2).join('-')
    end
    str << "-#{count.to_s}"
  end

  def generate_slug!
      slug = create_slug(self.send(self.class.slug_column.to_sym)) 
      i = 2
      record = self.class.find_by(slug: slug)
      while record && record != self
        slug = self.append_suffix(slug, i)
        record = self.class.find_by(slug: slug)
        i += 1
      end 
      self.slug = slug
  end

  module ClassMethods
    def sluggable_column(col_name)
      self.slug_column = col_name
    end
  end

end
