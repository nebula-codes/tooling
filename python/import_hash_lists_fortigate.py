count = 0
with open("import_hash_lists_fortigate.txt", "a") as file:
        file.write("config system external-resource\n")


for i in range(0,417):
    with open("import_hash_lists_fortigate.txt", "a") as file:
        file.write('edit "Virus Hash List ' + str(count) + '"\n')
        file.write("set type malware\n")
        if count < 10:
            file.write('set resource "https://virusshare.com/hashfiles/VirusShare_0000' + str(count) + '.md5"\n')
        elif count >=10 and count < 1000:
            file.write('set resource "https://virusshare.com/hashfiles/VirusShare_000' + str(count) + '.md5"\n')
        file.write("next\n")
    
    count += 1

with open("import_hash_lists_fortigate.txt", "a") as file:
        file.write("end")