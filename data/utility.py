import MySQLdb

def get_db_conn():
  return MySQLdb.connect(host="localhost",
                         user="root",
                         passwd="a",
                         db="webstars",
                         charset="utf8")
