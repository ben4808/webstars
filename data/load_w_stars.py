import codecs
import utility

db = utility.get_db_conn()
cur = db.cursor()

# reset table
cur.execute("delete from hip_stars")
cur.execute("alter table hip_stars auto_increment = 1")

# Create constellation index (abbr => id)
cons_ids = {}
cur.execute("select abbr, id from constellations")
results = cur.fetchall()
for res in results:
   cons_ids[res[0]] = res[1]

input = codecs.open("data/w_stars_v2.csv", "r", "utf-8")

# discard header
input.readline()

record_id = 0
records_per_query = 100
while(True):
  line = input.readline().strip()
  if(len(line) == 0):
    if(len(query) > 0):
      query = query[:-2]
      #print query
      #break
      cur.execute(query)
    break

  if(record_id % records_per_query == 0):
    query = "insert into hip_stars (hip, hd, constellation_id, ra_deg, dec_deg, mag, " + \
	    "bayer, flam, gould, name, is_common, var_name) values "

  tokens = line.split(",")

  # fill empty cells with null
  for i in range(len(tokens)):
    if(i != 15 and len(tokens[i].strip()) == 0):
      tokens[i] = "null"

  # calculate ra/dec in decimal degrees
  ra_deg = (int(tokens[3]) + int(tokens[4])/60.0 + float(tokens[5])/3600.0) * 15
  dec_deg = int(tokens[7]) + int(tokens[8])/60.0 + float(tokens[9])/3600.0
  if(tokens[6] == "-"):
    dec_deg *= -1

  # avoid end quote errors
  tokens[14] = tokens[14].replace("'", "\\'");

  query += "(" + tokens[0] + ", " + tokens[1] + ", " + str(cons_ids[tokens[2]]) + ", "
  query += str(ra_deg) + ", " + str(dec_deg) + ", " + tokens[10] + ", "
  for i in range(11, 17):
    if(tokens[i] == "null"):
      query += tokens[i]
    else:
      query += "'" + tokens[i] + "'"
    query += ", "
  query = query[:-2] + "), "

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
