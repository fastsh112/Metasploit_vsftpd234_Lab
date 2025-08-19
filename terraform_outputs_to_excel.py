import pandas as pd
import openpyxl
import re

#######################
# Parameters
output_file = 'FAST 2025-07-30.txt'
table_columns = ["Attendee Username", "Kali VM", "Kali Public IP", "Target VM", "Target Private IP"]
excel_file = 'metasploit_lab_instances.xlsx'
#######################

with open(output_file, 'r') as file:
    terraform_output = file.read()

pattern = r'(\w+)\s*:\s*{\s*no-op\s*kali_name\s*:\s*"([^"]+)"\s*no-op\s*kali_pub_ip\s*:\s*"([^"]+)"\s*no-op\s*target_name\s*:\s*"([^"]+)"\s*no-op\s*target_pri_ip\s*:\s*"([^"]+)"'
matches = re.findall(pattern, terraform_output)

df = pd.DataFrame(matches, columns=table_columns)

df.to_excel(excel_file, index=False)

print(f"Excel file created: {excel_file}")
