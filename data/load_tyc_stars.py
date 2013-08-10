import utility
import exceptions

db = utility.get_db_conn()
cur = db.cursor()

# reset table
cur.execute("delete from stars")
cur.execute("alter table stars auto_increment = 1")

input = open("hip_tyc/tyc_main.dat", "r")

record_id = 0
records_per_query = 100
while(True):
  line = input.readline().strip()
  if(len(line) == 0):
    break

  tokens = line.split("|")
  
  mag = 0
  try:
    mag = float(tokens[5])
  except exceptions.ValueError:
    continue
  if(mag <= 6.5):
    continue
  # if already in HIP catalogue
  if(len(tokens[31].strip()) != 0):
    continue

  if(record_id % records_per_query == 0):
    query = "insert into stars (hd, tyc1, tyc2, tyc3, ra_deg, dec_deg, mag) values "

  tyc_tok = tokens[1].split()
  hd = tokens[53].strip()
  if(len(hd) == 0):
    hd = 'null'

  ra_tok = tokens[3].split()
  ra = str(round((int(ra_tok[0]) + int(ra_tok[1])/60.0 + float(ra_tok[2])/3600.0)*15, 7))
  dec_tok = tokens[4].split()
  dec = str(round(int(dec_tok[0]) + int(dec_tok[1])/60.0 + float(dec_tok[2])/3600.0, 7))
  mag = tokens[5].strip()

  query += "(" + hd + ", " + tyc_tok[0] + ", " + tyc_tok[1] + ", " + tyc_tok[2] + \
	   ", " + ra + ", " + dec + ", " + mag + "), "

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
