import utility
import exceptions

db = utility.get_db_conn()
cur = db.cursor()

# reset table
cur.execute("delete from other_dsos")
cur.execute("alter table other_dsos auto_increment = 1")

input = open("data/SAC_dsos.csv", "r")
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
  
  if(record_id % records_per_query == 0):
    query = "insert into other_dsos (name, obj_type_id, ra_deg, dec_deg, size_maj, size_min, pa, mag) values "

  tokens[0] = " ".join(tokens[0].split()) # remove double whitespace
  query += "(" + "'" + tokens[0] + "'," + ",".join(tokens[1:]) + "), "
 
  record_id += 1
  if(record_id % records_per_query == 0):
    query = query[:-2]
    #print query
    #break
    if(record_id % 100000 == 0):
      print record_id
    cur.execute(query)

cur.execute("update other_dsos set mag=null where mag > 30")
db.commit()
cur.close()
input.close()

print "Done."
