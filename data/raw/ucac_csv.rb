filepath = "C:\\Users\\ben4808\\Desktop\\ucac4\\u4b\\z"

output = File.open("ucac_stars.csv", "w")
output.write("RA,Dec,Mag\n")

total = 0

900.times do |i|
	filename = filepath + ("%03d" % (i+1))
	puts filename + "  " + total.to_s + "\n"
	data = File.open(filename, "rb")

	while(record = data.read(78))
		ra_mas, dec_mas, millimag, buffer, flags = record.unpack('llsa52l')
		ht_flag = flags / 100000000
		mag = (millimag / 1000.0).round(2)
		next if (ht_flag != 0 or mag > 13)
	
		dec_mas = 324000000 - dec_mas # dec is originally in south pole declination
		ra_deg = (ra_mas / 3600000.0).round(7)
		dec_deg = (dec_mas / 3600000.0).round(7)
		#ra_h = (ra_deg / 15.0).floor
		#ra_m = ((ra_deg - (ra_h*15)) / 15.0 * 60.0).round(5)
		#dec_d = dec_deg.floor
		#dec_m = ((dec_deg - dec_d) * 60.0).round(5)
		#puts "RA " + ra_h.to_s + "h " + ra_m.to_s + "m\tDEC " + dec_d.to_s + " " + dec_m.to_s + "\tMAG " + mag.to_s + "\tFLAG " + ht_flag.to_s + "\n"
		
		output.write([ra_deg.to_s, dec_deg.to_s, mag.to_s].join(",") + "\n")
		total += 1
	end
	
	data.close()
end

output.close()