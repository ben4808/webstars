filename = "hip_tyc/hip_main.dat"

file = File.new(filename, "r")
output = File.new("hip_stars.csv", "w")
output.write("hip,hd,ra,dec,mag\n")
i = 1
while(line = file.gets)
	tokens = line.split("|").map {|token| token.strip}
	mag_f = tokens[5].to_f
	ra_tok = tokens[3].split
	ra = ((ra_tok[0].to_i + ra_tok[1].to_i/60.0 + ra_tok[2].to_f/3600.0)*15).round(7).to_s
	dec_tok = tokens[4].split
	dec = (dec_tok[0].to_i + dec_tok[1].to_i/60.0 + dec_tok[2].to_f/3600.0).round(7).to_s
	# minmag_f = tokens[50].to_f
	# is_double = tokens[59].length > 0 ? "1" : "0"
	# is_var = tokens[52].length > 0 ? "1" : "0"
	# min_mag = (is_var == "1" && (minmag_f - mag_f) >= 0.25) ? tokens[50] : ""
	# is_var = "0" if min_mag.length == 0
	output.write(tokens[1] + "," + tokens[71] + "," + ra + "," + dec + "," + tokens[5] + "\n")
	print i.to_s + "\n" if i%10000 == 0
	i += 1
end
file.close
