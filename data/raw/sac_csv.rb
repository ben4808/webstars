filename = "C:\\Users\\ben4808\\Desktop\\backup\\astronomy\\SAC.csv"

output = File.open("SAC_dsos.csv", "w")
output.write("name,obj_type_id,ra_deg,dec_deg,size_maj,size_min,pa,mag\n")

type_hash = {"GALXY" => 1, "G+C+N" => 2, "OPNCL" => 5, "PLNNB" => 4, "GALCL" => 1, "GLOCL" => 6, "DRKNB" => 3, "BRTNB" => 2, "SNREM" => 2, "QUASR" => 1, "CL+NB" => 5}

lines = IO.readlines(filename)
lines.each_with_index do |line, i|
	next if i == 0
	line.strip!
	tokens = line.split(",").map {|tok| tok.strip}
	next if (tokens[0].start_with? "NGC" or tokens[0].start_with? "IC")
	next if !type_hash.include? tokens[2]
	
	name = tokens[0]
	type = type_hash[tokens[2]].to_s
	ra_tok = tokens[4].split
	ra_deg = ((ra_tok[0].to_i + ra_tok[1].to_f / 60.0) * 15).round(4).to_s
	dec_tok = tokens[5].split
	dec_deg = (dec_tok[0].to_i + dec_tok[1].to_i / 60.0).round(4).to_s
	
	size_maj = "null"
	size_maj = (tokens[10].to_f).round(2).to_s if tokens[10].end_with? "m"
	size_maj = (tokens[10].to_f / 60.0).round(2).to_s if tokens[10].end_with? "s"
	
	size_min = "null"
	size_min = (tokens[11].to_f).round(2).to_s if tokens[11].end_with? "m"
	size_min = (tokens[11].to_f / 60.0).round(2).to_s if tokens[11].end_with? "s"
	
	pa = "null"
	pa = (tokens[12].to_i).to_s if !tokens[12].empty?
	
	mag = (tokens[6].to_f).round(1).to_s
	mag = "null" if mag == "99.9"
		
	output.write([name, type, ra_deg, dec_deg, size_maj, size_min, pa, mag].join(",") + "\n")
end

output.close()