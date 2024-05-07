# Author: Wojciech Knopp
# Program to convert a bitmap image to a black and white or grayscale image

Black = Array[0, 0, 0]
White = Array[255, 255, 255]
Black4 = Array[0, 0, 0, 255]
White4 = Array[255, 255, 255, 255]

$pixel_size = 3

def get_pixels(image_data)
    # skip header
    image_data = image_data.unpack("C*")
    # image_pixels_data = image_data[54..-1]
    image_pixels_data = image_data[138..-1]

    # pack image data for memory saving
    image_data = image_data.pack("C*")

    # split data string into array of pixels
    pixels = image_pixels_data.each_slice($pixel_size).to_a

    # get sizes
    # image_width = image_data[18..21].unpack("L*")[0]
    # image_height = image_data[22..25].unpack("L*")[0]

    return pixels
end

def convert_to_bw(pixels)
    # duplicate pixels array
    mod_pixels = pixels.dup
    # get shade from user
    print "Enter max shade of pixel that will be converted to black pixel (1-254) (more whites - more blacks) [default: 127]:"
    shade = gets.chomp.to_i
    if shade < 1 || shade > 254
        shade = 127
    end

    puts "Converting image..."
    for i in 0..pixels.length-1
        avg = (pixels[i][0] + pixels[i][1] + pixels[i][2]) / 3
        # if pixels[i][0] < shade
        #     pixels[i] = Black
        # else
        #     pixels[i] = White
        # end
        if avg < shade
            if $pixel_size == 3
                mod_pixels[i] = Black
            else
                mod_pixels[i] = Black4
            end
        else
            if $pixel_size == 3
                mod_pixels[i] = White
            else
                mod_pixels[i] = White4
            end
        end
    end
    return mod_pixels
end

def convert_to_grayscale(pixels)
    # duplicate pixels array
    mod_pixels = pixels.dup
    puts "Converting image..."
    puts "before conversion"
    for i in 0..10
        print pixels[i] 
        print " avg: "
        print (pixels[i][0] + pixels[i][1] + pixels[i][2]) / 3
        print "\n"
    end

    for i in 0..pixels.length-1
        avg = (pixels[i][0] + pixels[i][1] + pixels[i][2]) / 3
        if $pixel_size == 3
            mod_pixels[i] = Array[avg, avg, avg]
        else
            mod_pixels[i] = Array[avg, avg, avg, 255]
        end
    end

    puts "converted"
    for i in 0..10
        print mod_pixels[i] 
        print " avg: "
        print (pixels[i][0] + pixels[i][1] + pixels[i][2]) / 3
        print "\n"
    end
    return mod_pixels
end

print "BMP Image name: "
image_name = gets.chomp
plain = File.open(image_name, "rb")
puts "Reading plain image..."
# read plain image
image_data = plain.read
# save header
# header = image_data[0..53]
header = image_data[0..137]

# print fragment to decide on pixel size
tmp = image_data[138..169].unpack("C*")
tmp2 = tmp.each_slice(3).to_a
for i in 0..tmp2.length-1
    print tmp2[i]
    puts
end
print "Looking at the fragment above, what is the size of a pixel in bytes? (3 or 4): "
$pixel_size = gets.chomp.to_i

# get pixels
pixels = get_pixels(image_data)

# print pixel colors
for i in 0..10
    print pixels[i] 
    print " avg: "
    print (pixels[i][0] + pixels[i][1] + pixels[i][2]) / 3
    print "\n"
end

while true
    puts "Choose conversion type:"
    puts "1. Black and white"
    puts "2. Grayscale"

    choice = gets.chomp.to_i
    if choice == 1
        # convert to black and white
        mod_pixels = convert_to_bw(pixels)
    elsif choice == 2
        # convert to grayscale
        mod_pixels = convert_to_grayscale(pixels)
    else
        puts "Invalid choice"
        exit
    end

    # pack pixels
    mod_image_data = mod_pixels.flatten.pack("C*")
    modified_image = header + mod_image_data
    # save black and white image
    print "Saving black and white image to: "
    mod_image_name = gets.chomp
    mod_image = File.open(mod_image_name, "wb")
    mod_image.write(modified_image)
    mod_image.close

    puts "Conversion complete"
    print "Do you want to convert image again? (y/n): "
    again = gets.chomp
    if again != "y"
        break
    end
end
