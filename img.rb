require 'rmagick'
include Magick


		#this will be the final image
	big_image = ImageList.new

	#this is an image containing first row of images
	first_row = ImageList.new
	#this is an image containing second row of images
	second_row = ImageList.new

	#adding images to the first row (Image.read returns an Array, this is why .first is needed)
	imgs_only = []

	Dir.entries(".").each do |e|
		imgs_only << e if e[-3..-1] == 'png'
	end

	num_imgs = imgs_only.size

	imgs_only[0..num_imgs / 2].each do |e|
		first_row.push(Image.read(e).first)
	end


	#adding first row to big image and specify that we want images in first row to be appended in a single image on the same row - argument false on append does that
	big_image.push (first_row.append(false))

	#same thing for second row
	imgs_only[((num_imgs/2)+1)..-1].each do |e|
		second_row.push(Image.read(e).first)
	end

	big_image.push(second_row.append(false))

	#now we are saving the final image that is composed from 2 images by sepcify append with argument true meaning that each image will be on a separate row
	big_image.append(true).write("big_image.png")
	image_made = 1
end


