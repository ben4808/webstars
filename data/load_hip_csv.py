import MySQLdb

db = MySQLdb.connect(host="localhost", user="root", passwd="astron", db="starmap")
cur = db.cursor() 
cur.execute("delete from stars")

filename = "hip_stars.csv"
file = open(filename, "r")

i = 0
records = []
for line in file:
	i += 1
	if(i == 1):
		continue
#	if(i > 10):
#		break
#	if(i > 2):
#		query += ", "
	tokens = line.split(",")
	hip = tokens[0]
	ra_tok = tokens[1].split()
	ra_h = ra_tok[0]
	ra_m = ra_tok[1]
	ra_s = ra_tok[2]
	dec_tok = tokens[2].split()
	dec_deg = dec_tok[0]
	dec_m = dec_tok[1]
	dec_s = dec_tok[2]
	mag = tokens[3].strip()
	if(len(mag) == 0):
		continue;
	is_double = tokens[4]
	is_var = tokens[5]
	min_mag = tokens[6].strip()
	if(min_mag == ""):
		min_mag = "null"
	
	records.append("(" + hip + ", " + ra_h + ", " + ra_m + ", " + ra_s + ", " + dec_deg + ", " + dec_m + ", " + dec_s + ", " + mag + ", " + is_double + ", " + is_var + ", " + min_mag + ")")
	if(i%10000 == 0):
		print str(i)
	
#print query

query_start = "insert into stars (hip, ra_h, ra_m, ra_s, dec_deg, dec_m, dec_s, mag, is_double, is_var, min_mag) values "
i = 0
while i < len(records):
	query = query_start[:]
	for j in range(100):
		if(i >= len(records)):
			break
		if(j > 0):
			query += ", "
		query += records[i]
		i += 1
		if(i%10000 == 0):
			print str(i)
	cur.execute(query)

db.commit()
cur.close()
db.close()