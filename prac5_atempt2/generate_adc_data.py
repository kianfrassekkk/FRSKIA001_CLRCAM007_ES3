import random

# Generate list of random numbers between 0 and 200
data_list = [random.randint(0, 200) for _ in range(255)]

# Modify 180th and 200th value to be between 220 and 255
data_list[179] = random.randint(220, 255)
data_list[199] = random.randint(220, 255)

# Open the CSV file for writing (replace "adc_data.csv" with your desired filename)
with open("adc_data.csv", "w") as csvfile:
  # Write the data to the CSV file, one value per line
  for value in data_list:
    csvfile.write(str(value) + "\n")

print("Data written to adc_data.csv")