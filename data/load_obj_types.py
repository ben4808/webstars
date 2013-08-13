import utility

db = utility.get_db_conn()
cur = db.cursor()

# reset table
cur.execute("delete from obj_types")
cur.execute("alter table obj_types auto_increment = 1")

# repopulate table
file = open("data/objtypes.csv", "r")
file.readline() # discard header

query = "insert into obj_types (name, abbr) values "
while(True):
  line = file.readline().strip()
  if(len(line) == 0):
    break
  tokens = line.split(",")
  query += "('" + tokens[0].strip() + "', '" + tokens[1].strip() + "'), "

# print query
cur.execute(query[:-2]) # remove trailing comma

db.commit()
cur.close()
file.close()

print "Done."
