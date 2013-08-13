import utility
import exceptions

db = utility.get_db_conn()
cur = db.cursor()

# build constellation index
cons_ids = {}
cur.execute("select abbr, id from constellations")
results = cur.fetchall()
for res in results:
   cons_ids[res[0].lower()] = res[1]

# reset table
cur.execute("delete from ngcic_dsos")
cur.execute("alter table ngcic_dsos auto_increment = 1")

input = open("data/NI2012.csv", "r")

input.readline() # discard header

type_map = {1:1, 2:2, 3:4, 4:5, 5:6, 6:2}

record_id = 0
records_per_query = 100
while(True):
  line = input.readline().strip()
  if(len(line) == 0):
    break

  tokens = line.split(",")
  if(int(tokens[5]) > 6):
     continue
 
  if(record_id % records_per_query == 0):
    query = "insert into ngcic_dsos (ngc, ic, obj_type_id, constellation_id, ra_deg, dec_deg, mag, size_maj, size_min, pa, name, description, other_ngc, mess, cald, ugc, mcg, cgcg, pgc, arp, eso, pk, ocl, gcl) values "

  quotes = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  vals = []
  ni_num = tokens[1] + tokens[2]
  if(len(tokens[3].strip()) > 0):
     ni_num += "_" + tokens[3]
  vals.append(ni_num if tokens[0] == "N" else "null") #ngc
  vals.append(ni_num if tokens[0] == "I" else "null") #ic
  vals.append(str(type_map[int(tokens[5])])) #obj_type_id
  vals.append(cons_ids[tokens[7].lower()]) # constellation_id
  ra = str(round((int(tokens[8]) + int(tokens[9])/60.0 + float(tokens[10])/3600.0)*15, 7))
  vals.append(ra) #ra_deg
  dec = int(tokens[12]) + int(tokens[13])/60.0 + float(tokens[14])/3600.0
  if(tokens[11].strip() == "-"):
    dec *= -1
  dec = str(round(dec, 7))
  vals.append(dec) #dec_deg
  vals.append(tokens[16] if len(tokens[16].strip()) > 0 else "null") #mag
  vals.append(tokens[19] if len(tokens[19].strip()) > 0 else "null") #size_maj
  vals.append(tokens[20] if len(tokens[20].strip()) > 0 else "null") #size_min
  vals.append(tokens[21] if len(tokens[21].strip()) > 0 else "null") #pa
  vals.append("null") #name
  vals.append("null") #description
  vals.append("null") #other_ngc, to be filled in in next section

  catalogs = []
  for i in range(11):
     catalogs.append("null")
  if(len(tokens[26].strip()) > 0):
     catalogs[5] = tokens[26] #pgc
  catalog_vals = {"M":0, "C":1, "UGC":2, "MCG":3, "CGCG":4, "Arp":6, "ESO":7, "PK":8, "OCL":9, "GCL":10}
  for i in range(27, 38):
     if(len(tokens[i].strip()) == 0):
	break
     cat_tokens = tokens[i].split()
     if(cat_tokens[0] == "NGC" or cat_tokens[0] == "IC"):
	if(vals[12] == "null"):
	   vals[12] = ""
	else:
	   vals[12] += "; "
	vals[12] += cat_tokens[0] + " " + cat_tokens[1]
     elif(cat_tokens[0] in catalog_vals):
	catalogs[catalog_vals[cat_tokens[0]]] = cat_tokens[1]

  for i in range(11):
     vals.append(catalogs[i])

  query += "("
  i = 0
  for val in vals:
     query += "'" if quotes[i] == 1 and val != "null" else ""
     query += str(val)
     query += "'" if quotes[i] == 1 and val != "null" else ""
     query += ", " if i != len(vals)-1 else ""
     i += 1
  query += "), "
 
  record_id += 1
  if(record_id % records_per_query == 0):
    query = query[:-2]
    #print query
    #break
    cur.execute(query)

db.commit()
cur.close()
input.close()

print "Done."
