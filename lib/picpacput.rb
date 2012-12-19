#!/usr/bin/ruby

require 'find'
#require 'tmpdir' # Dir.tmpdir
require 'rubygems'
require 'RMagick'
require 'zip/zip'


class PicPacPut
  attr_accessor :folder, :recursive, :extension, :scale_by, :outfolder, :ext_types

  def initialize( opts = {} )
    options = {
      :folder => ('.'+File::SEPARATOR),
      :recursive => true,
      :extension => "*.JPG",
      :scale_by => 0.05,
      :zipFile => 'output.zip',
      :outfolder => ('resized'+File::SEPARATOR),
      :ext_types => ["png","PNG","jpg","JPG","jpeg","JPEG","gif","GIF","bmp","BMP"]
    }.merge(opts)
    @folder = options[:folder]
    @recursive = options[:recursive]
    @extension = options[:extension]
    @scale_by = options[:scale_by]
    @outfolder = options[:outfolder]
    @zipFile = options[:zipFile]
    @ext_types = options[:ext_types]
    Dir.mkdir(@outfolder) unless File.exists?(@outfolder)
  end
  
  def thumbOne(image_in = @folder + @extension )
    puts "STATUS #{image_in}"
    if File.exists?(image_in)
      image = Magick::Image.read(image_in).first
      new_image = image.scale(@scale_by)
      if not File.exists?(@outfolder + image.filename.split(File::SEPARATOR)[-1])
        new_image.write(@outfolder + image.filename.split(File::SEPARATOR)[-1])
      else
        puts "File #{ @outfolder + image.filename } already exists!  Please change your output."
      end
      [image,new_image].each { |img| img.destroy! } # IMPORTANT!!!
    else
      raise "File #{image_in} does not exist!"
    end
  end
  
  def thumbit    
    if !!@extension["*"] # blob operator
      Dir.glob("#{@folder + @extension}") do |f|
        thumbOne(f)
      end
    else
      thumbOne      
    end
  end
  
  def pic
    if not @recursive
      return thumbit
    end
    dirList = []
    Find.find(@folder) do |f|
      if !!f[@outfolder]
        next
      end
      @ext_types.each do |type|
        ext = f.match(".#{type}")
        if not ext.nil?
          dirList << f
	  thumbOne(f)# maybe CWD + directory
        end
      end
    end
    dirList
  end

  def pac
    Zip::ZipFile.open( @outfolder + File::SEPARATOR + @zipFile, Zip::ZipFile::CREATE) do |zipfile|
      Dir.glob( @outfolder + File::SEPARATOR + '*' ).each do |filename|
        filename.gsub!(File::SEPARATOR*2, File::SEPARATOR)
        if File.directory?(filename) or !!filename[@zipFile]
          next
        end
        zipfile.add(filename, filename)
      end
    end
  end
end

#picpacput = PicPacPut.new
#picpacput.pic
#picpacput.pac
