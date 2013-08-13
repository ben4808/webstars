filepath = "C:\\Users\\ben4808\\Desktop\\backup\\astronomy\\Tycho2\\tyc2.dat."
tyc_hds = "C:\\Users\\ben4808\\Desktop\\tyc_hds.csv"

output = File.open("tyc2_stars2.csv", "w")
output.write("hd,tyc1,tyc2,tyc3,ra_deg,dec_deg,mag\n")

hds = File.open(tyc_hds, "r")
hds.readline
hd_tok = hds.readline.split(",").map {|tok| tok.to_i}

total = 0
1.times do |i|
	filename = filepath + ("%02d" % (i+19))
	puts filename + "  " + total.to_s + "\n"
	lines = IO.readlines(filename)

	lines.each do |line|
		line.strip!
		tokens = line.split("|").map {|tok| tok.strip}
		next if (tokens[2].empty? || tokens[3].empty? || tokens[19].empty? || !tokens[23].empty?)
		ra_deg = tokens[2].to_f.round(7).to_s
		dec_deg = tokens[3].to_f.round(7).to_s
		mag = tokens[19].to_f.round(2).to_s
		tyc_tok = tokens[0].split.map {|tok| tok.to_i}
		next if tyc_tok[2].to_i != 1
		
		hd = "null"
=begin
		if (tyc_tok[0] == hd_tok[0] && tyc_tok[1] == hd_tok[1] && tyc_tok[2] == hd_tok[2])
			hd = hd_tok[3].to_s
			#hd_tok = hds.readline.split(",").map {|tok| tok.to_i}
		end
		hd_tok = hds.readline.split(",").map {|tok| tok.to_i} until (hd_tok[2] == 1 and (hd_tok[0] > tyc_tok[0] or hd_tok[1] > tyc_tok[1]))
=end
		
		output.write([hd, tyc_tok[0], tyc_tok[1], tyc_tok[2], ra_deg, dec_deg, mag].join(",") + "\n")
		total += 1
		#break if total > 100
	end
end

output.close()