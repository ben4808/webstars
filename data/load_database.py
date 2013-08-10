import MySQLdb
import codecs

file = codecs.open("w_stars.csv", encoding="utf-8", mode="r")
file.readline() # header line

while(True):
   line = file.readline().strip()
   if(len(line) == 0):
      break

   tokens = line.split(",")
   
