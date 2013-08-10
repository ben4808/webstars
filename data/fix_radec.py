import codecs

input = codecs.open("w_stars.csv", "r", "utf-8")
output = codecs.open("w_stars_new.csv", "w", "utf-8")

# copy header
output.write(input.readline())

while(True):
  line = input.readline().strip()
  if(len(line) == 0):
    break

  tokens = line.split(",")

  sign = ""
  dec_deg = int(tokens[7])
  if(dec_deg == 0):
    sign = "???"
  elif(dec_deg < 0):
    tokens[7] = tokens[7][1:]
    sign = "-"
  else:
    sign = "+"

  tokens[6] = sign
  output.write(",".join(tokens) + "\n")

output.close()
input.close()
