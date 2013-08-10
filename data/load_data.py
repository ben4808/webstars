# coding: utf-8

import sys
import re
import codecs
import MySQLdb
import requests

if(len(sys.argv) != 2):
   print(
"""USAGE: must specify which data to load:
c: constellations
w: wikipedia stars""")
   exit(1)

data_to_load = sys.argv[1]

db = MySQLdb.connect(host="localhost", 
                     user="root", 
                     passwd="a", 
                     db="starmap",
                     charset="utf8")
cur = db.cursor()

cons_ids = {}
cons_ids_lower = {}

# Constellations
if("c" in data_to_load):
   print "Updating constellations..."
   cur.execute("delete from constellations")
   cur.execute("alter table constellations auto_increment = 1")
   file = open("constellations.csv", "r")
   i=0
   query = "insert into constellations (name, abbr) values "
   for line in file:
      i += 1
      if(i==1):
	 continue
      tokens = line.split(",")
      if(i > 2):
	 query += ", "
      query += "('" + tokens[0].strip() + "', '" + tokens[1].strip() + "')"
   #print query
   cur.execute(query)

cur.execute("select abbr, id from constellations")
results = cur.fetchall()
for res in results:
   cons_ids[res[0]] = res[1]
   cons_ids_lower[res[0].lower()] = res[1]

if("w" in data_to_load):
   print "Loading Wikipedia stars..."
   output = codecs.open("w_stars_new.csv", encoding="utf-8", mode="w")
   column_flags = {}

   output_cols = ["hip","hd","cons","ra_h","ra_m","ra_s","dec_deg","dec_m","dec_s",
                  "mag","bayer","flam","gould","name","is_double","is_var","max_mag","min_mag"]
   ol = ""
   i = 0
   for token in output_cols:
      if(i > 0):
	 ol += ","
      ol += token
      i += 1
   output.write(ol + "\n")

   cur.execute("select id, name, abbr from constellations")
   results = cur.fetchall()
   for res in results:
      cons = res[2]
      name = res[1].replace(" ", "_")
      print res[1]
      if(name != "Taurus"):
	 continue
      page = requests.get("http://en.wikipedia.org/wiki/List_of_stars_in_" + name)
      header_text = ["B", "F", "G.", "HD", "HIP", "RA", "Dec", "mag."]
      for token in header_text:
	 column_flags[token] = False
      column_i = 0
      for line in page.text.split("\n"):
	 if("</th>" in line):
	    for token in header_text:
	       if((token + "</a></th>") in line and column_flags[token] == False):
		  column_flags[token] = column_i
		  break
	       if((name == "Ophiuchus" or name == "Serpens") and token == "G."):
		  column_flags[token] = column_i
		  break 
	    column_i += 1

      c2_i = -1
      offset = False
      if(column_flags["F"] != False):
	 c2_i = 11
	 if(column_flags["G."] != False):
	    offset = True
      else:
	 c2_i = 12

      """
      ol = name + ": "
      for token in header_text:
	 if(column_flags[token] == False and token != "F" and token != "G."):
	    ol += "ERROR: Missing token " + token
	    exit(1)
	 if(column_flags[token] != False):
	    ol += token + " " 
		  
      output.write(ol + "\n")
      """   

      lines = page.text.split("\n")
      index = 0
      while("Notes</th>" not in lines[index]):
	 index += 1
      index += 2

      #rows
      while(True):
	 throw_out_row = False
	 index += 1

	 row_vals = []
	 for token in output_cols:
	    row_vals.append("")

	 line = lines[index]
	 if("<td" not in line):
	    break
	 #cells
	 i=0
	 while(True):
	    line = lines[index]
            if("</tr>" in line):
	       break
	    if("<td" not in line):
	       index += 1
	       continue
	    line = re.sub(r"<.*?>", "", line)
	    line = re.sub(r"\[.*?\]", "", line)
	    col_i = {
	       0 : -1,
               1 : 10,
               2 : c2_i,
               3 : 12 if offset else 1,
               4 : 1 if offset else 0,
               5 : 0 if offset else 3,
               6 : 3 if offset else 6,
               7 : 6 if offset else 9,
               8 : 9 if offset else -1,
               9 : -1, 8: -1, 
               11: -1 if offset else -1, 
               12: -1 if offset else -1}[i]
	    i += 1
	    index += 1
	    if(col_i == -1):
	       continue
	    if(col_i == 3 or col_i == 6):
               line = line.replace("&#160;", " ")
               line = line.replace(u"−", "-")
	       line = re.sub(r"[^0-9\-\. ]", "", line)
	       tokens = line.split()
	       if(len(tokens) == 3):
		  for j in range(3):
		     row_vals[col_i + j] = tokens[j]
	       else:
		  throw_out_row = True
	    elif col_i == 9:
               line = line.replace(u"−", "-")
	       try:
		  mag = float(line)
		  if(mag > 6.50):
		     throw_out_row = True
               except ValueError:
		  throw_out_row = True
	       row_vals[col_i] = line
            elif col_i == 12:
	       line = line.replace(" Cap", "")
               line = line.replace(" Cau", "")
               row_vals[col_i] = line
	    elif col_i != -1:
	       row_vals[col_i] = line
	   
         row_vals[2] = cons
         if(row_vals[0] == "" and row_vals[1] == ""):
	    throw_out_row = True 
	 index += 1

	 if(throw_out_row):
	    continue

	 ol = ""
	 i = 0
	 for token in row_vals:
	    if(i > 0):
	       ol += ","
	    ol += token
	    i += 1
	 output.write(ol + "\n")
   output.close()

if("d" in data_to_load):
   print "Loading Wikipedia stars into database..."
   file = codecs.open("w_stars.csv", encoding="utf-8", mode="r")
   file.readline() # header line

   lines = []
   while(True):
      line = file.readline().strip()
      if(len(line) == 0):
	 break
      lines.append(line)
   file.close()

   i = 0
   query = ""
   for line in lines:
      if(i%100 == 0):
	 query = "insert into hip_stars (hip, hd, cons, ra_h, ra_m, ra_s, dec_deg, dec_m, dec_s, mag, bayer, flam, gould, name, is_double, is_var, var_name, max_mag, min_mag) values "
      tokens = line.split(",")
      quotes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0]
      query += "("
      token_i = 0
      for token in tokens:
	 if(len(token) > 0):
	    token = token.replace("'", "\\'");
	    query += "'" if quotes[token_i] == 1 else ""
	    query += str(cons_ids[token]) if token_i == 2 else token
	    query += "'" if quotes[token_i] == 1 else ""
	    query += ", " if token_i != len(tokens) - 1 else ""
	 else:
	    query += "null, " if token_i != len(tokens) - 1 else "null"
	 token_i += 1
      query += ")" if i%100 == 99 or i == len(lines) - 1 else "), "
      if(i%100 == 99 or i == len(lines) - 1):
	 cur.execute(query)
         #print str(i+1)
      i += 1

if("h" in data_to_load):
   print "Loading Hipparcos Catalog..."
   already_loaded = {}
   cur.execute("select hip from hip_stars where hip is not null")
   results = cur.fetchall()
   for result in results:
      already_loaded[result[0]] = 1

   file = open("hip_tyc/hip_main.dat", "r")
   line_i = 0
   query_i = 0
   query = ""
   while(True):
      line = file.readline().strip()
      if(len(line) == 0):
	 query = query[:-2]
	 #print query
	 cur.execute(query)
	 print line_i
	 break

      if(query_i%100 == 0):
	 query = "insert into hip_stars (hip, hd, cons, ra_h, ra_m, ra_s, dec_deg, dec_m, dec_s, mag, bayer, flam, gould, name, is_double, is_var, var_name, max_mag, min_mag) values "

      tokens = line.split("|")

      hip = int(tokens[1])
      if(hip in already_loaded):
	 line_i += 1
	 continue

      quotes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0]
      vals = []
      vals.append(tokens[1] if len(tokens[1].strip()) > 0 else "null") # hip
      vals.append(tokens[71] if len(tokens[71].strip()) > 0 else "null") # hd
      vals.append("null") # cons
      ra_tokens = tokens[3].split()
      vals.append(ra_tokens[0]) # ra_h
      vals.append(ra_tokens[1]) # ra_m
      vals.append(ra_tokens[2]) # ra_s
      dec_tokens = tokens[4].split()
      vals.append(dec_tokens[0]) # dec_deg
      vals.append(dec_tokens[1]) # dec_m
      vals.append(dec_tokens[2]) # dec_s
      vals.append(tokens[5] if len(tokens[5].strip()) > 0 else "null") # mag
      vals.append("null") # bayer
      vals.append("null") # flam
      vals.append("null") # gould
      vals.append("null") # name
      vals.append("0") # is_double
      vals.append("0") # is_var
      vals.append("null") # var_name
      vals.append("null") # mag_mag
      vals.append("null") # min_mag

      query += "("
      token_i = 0
      for val in vals:
	 val = val.replace("'", "\\'");
	 query += "'" if quotes[token_i] == 1 and val != "null" else ""
	 query += val.strip()
	 query += "'" if quotes[token_i] == 1 and val != "null" else ""
	 query += ", " if token_i != len(vals) - 1 else ""
	 token_i += 1
      query += ")" if query_i%100 == 99  else "), "
      if(query_i%100 == 99):
	 #print query
	 cur.execute(query)
         if(line_i%10000 < 100):
	    print str(line_i+1)
	 #break
      query_i += 1
      line_i += 1

if("t" in data_to_load):
   print "Loading Tycho-2 Catalog..."

   file = open("hip_tyc/tyc_main.dat", "r")
   line_i = 0
   query_i = 0
   query = ""
   while(True):
      line = file.readline().strip()
      if(len(line) == 0):
	 query = query[:-2]
	 #print query
	 cur.execute(query)
	 print line_i
	 break

      if(query_i%100 == 0):
	 query = "insert into stars (hd, tyc1, tyc2, tyc3, ra_h, ra_m, ra_s, dec_deg, dec_m, dec_s, mag, is_double, is_var) values "

      tokens = line.split("|")

      if(len(tokens[31].strip()) > 0):
	 line_i += 1
	 continue

      vals = []
      vals.append(tokens[53] if len(tokens[53].strip()) > 0 else "null") # hd
      ty_tokens = tokens[1].split()
      vals.append(ty_tokens[0]) # tyc1
      vals.append(ty_tokens[1]) # tyc2
      vals.append(ty_tokens[2]) # tyc3
      ra_tokens = tokens[3].split()
      vals.append(ra_tokens[0]) # ra_h
      vals.append(ra_tokens[1]) # ra_m
      vals.append(ra_tokens[2]) # ra_s
      dec_tokens = tokens[4].split()
      vals.append(dec_tokens[0]) # dec_deg
      vals.append(dec_tokens[1]) # dec_m
      vals.append(dec_tokens[2]) # dec_s
      vals.append(tokens[5] if len(tokens[5].strip()) > 0 else "null") # mag
      vals.append("0") # is_double
      vals.append("0") # is_var

      query += "("
      token_i = 0
      for val in vals:
	 val = val.replace("'", "\\'");
	 query += val.strip()
	 query += ", " if token_i != len(vals) - 1 else ""
	 token_i += 1
      query += ")" if query_i%100 == 99  else "), "
      if(query_i%100 == 99):
	 #print query
	 cur.execute(query)
         if(line_i%10000 < 100):
	    print str(line_i+1)
	 #break
      query_i += 1
      line_i += 1
   cur.execute("delete from stars where mag < 6.5") # wikipedia star duplicates
   file.close()

if("o" in data_to_load):
   print "Loading object types..."

   cur.execute("delete from obj_types")
   cur.execute("alter table obj_types auto_increment = 1")
   file = open("objtypes.csv", "r")
   file.readline()

   query = "insert into obj_types (name, abbr) values "
   while(True):
      line = file.readline().strip()
      if(len(line) == 0):
	 break
      tokens = line.split(",")
      query += "('" + tokens[0] + "', '" + tokens[1] + "'), "
   cur.execute(query[:-2])
   file.close()

if("n" in data_to_load):
   print "Loading NGC/IC data into database..."

   cur.execute("delete from deepsky")
   file = open("NI2012.csv", "r")    
   file.readline()

   type_map = {1:1, 2:2, 3:4, 4:5, 5:6, 6:2}
   query_i = 0
   while(True):
      line = file.readline().strip()

      if(len(line.strip()) == 0):
	 query = query[:-2]
	 #print query
	 print query_i
	 cur.execute(query)
	 break

      if(query_i%100 == 0):
         query = "insert into deepsky (ngc, ic, obj_type, cons, ra_h, ra_m, ra_s, dec_deg, dec_m, dec_s, mag, size_maj, size_min, pa, name, description, other_ngc, mess, cald, ugc, mcg, cgcg, pgc, arp, eso, pk, ocl, gcl) values "

      tokens = line.split(",")
      if(int(tokens[5]) > 6):
	 continue

      quotes = [1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
      vals = []
      ni_num = tokens[1] + tokens[2]
      if(len(tokens[3].strip()) > 0):
	 ni_num += "_" + tokens[3]
      vals.append(ni_num if tokens[0] == "N" else "null") #ngc
      vals.append(ni_num if tokens[0] == "I" else "null") #ic
      vals.append(str(type_map[int(tokens[5])])) #obj_type
      vals.append(cons_ids_lower[tokens[7].lower()]) # cons
      vals.append(tokens[8]) #ra_h
      vals.append(tokens[9]) #ra_m
      vals.append(tokens[10]) #ra_s
      vals.append(tokens[11] + tokens[12]) #dec_deg
      vals.append(tokens[13]) #dec_m
      vals.append(tokens[14]) #dec_s
      vals.append(tokens[16] if len(tokens[16].strip()) > 0 else "null") #mag
      vals.append(tokens[19] if len(tokens[19].strip()) > 0 else "null") #size_maj
      vals.append(tokens[20] if len(tokens[20].strip()) > 0 else "null") #size_min
      vals.append(tokens[21] if len(tokens[21].strip()) > 0 else "null") #pa
      vals.append("null") #name
      vals.append("null") #description
      vals.append("null") #other_ngc

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
	    if(vals[16] == "null"):
	       vals[16] = ""
	    else:
	       vals[16] += "; "
	    vals[16] += cat_tokens[0] + " " + cat_tokens[1]
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

      if(query_i%100 == 99):
	 query = query[:-2]
	 #print query
	 if(query_i%1000 == 99):
	    print query_i
	 cur.execute(query)

      query_i += 1

   file.close()

db.commit()
cur.close()
db.close()

print "Done."
