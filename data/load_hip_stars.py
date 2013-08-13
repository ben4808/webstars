import utility
import exceptions

db = utility.get_db_conn()
cur = db.cursor()

# Not resetting table since it is assumed the Wikipedia stars (mag <= 6.5) are already loaded
# Also, no constellations will be loaded with these stars.

input = open("data/hip_stars.csv", "r")

# discard header
input.readline()

record_id = 0
records_per_query = 100
while(True):
  line = input.readline().strip()
  if(len(line) == 0):
    break

  tokens = line.split(",")
  
  mag = 0
  try:
    mag = float(tokens[4])
  except exceptions.ValueError:
    print tokens[0]
  if(mag <= 6.5):
    continue

  if(record_id % records_per_query == 0):
    query = "insert into hip_stars (hip, hd, ra_deg, dec_deg, mag) values "

  if(len(tokens[1]) == 0):
    tokens[1] = "null"

  query += "("
  for i in range(0, len(tokens)):
    query += tokens[i] + ", "
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
