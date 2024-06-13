import csv;

stations = []

with open('stations.csv') as file:
    csv_reader = csv.reader(file, delimiter=',')

    line_count = 0
    for line in csv_reader:
        if line_count == 0:
            line_count += 1
            continue
        else:
            line_count += 1
            stations.append([line[0], line[1], line[2], line[3]])

generated_file = """const List<String> crsList = [\n"""

for station in stations:
    generated_file += f"  \"{station[3]}\",\n"

generated_file += '];\n'

with open('../lib/crs_list.g.dart', 'w') as file:
    file.write(generated_file)

print("Written to ../lib/crs_list.g.dart")