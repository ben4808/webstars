import utility
import exceptions

db = utility.get_db_conn()
cur = db.cursor()

# reset table
cur.execute("delete from ucac_stars")
cur.execute("alter table ucac_stars auto_increment = 1")

input = open("data/ucac_stars.csv", "r")
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
      if(record_id % 100000 == 0):
	print record_id
      cur.execute(query)
    break

  tokens = line.split(",")
  mag = float(tokens[6])
  if(mag <= 6.5):
    continue
  
  if(record_id % records_per_query == 0):
    query = "insert into ucac_stars (ra_deg, dec_deg, mag) values "

  query += "(" + ",".join(tokens) + "), "
 
  record_id += 1
  if(record_id % records_per_query == 0):
    query = query[:-2]
    #print query
    #break
    if(record_id % 100000 == 0):
      print record_id
    cur.execute(query)

db.commit()
cur.close()
input.close()

print "Done."
