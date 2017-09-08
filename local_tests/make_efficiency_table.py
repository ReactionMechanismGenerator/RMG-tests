import pandas as pd

data = pd.DataFrame(columns=['memory benchmark','memory new','time benchmark','time new'])

with open('main_log.out') as f:

    next_line_contains_data = [False,False,False,False]

    for line in f.readlines():
        if 'Running' in line:
            current_example = line.split()[1]
        elif any(next_line_contains_data):
            if any(next_line_contains_data[:2]): # indicates memory
                data_in_line = -2
            else:
                data_in_line = -1
            data.loc[current_example,data.columns[next_line_contains_data]] = line.split()[data_in_line]
            next_line_contains_data = [False,False,False,False]
        elif 'Execution time, Benchmark:' in line:
             next_line_contains_data[2] = True
        elif 'Execution time, Tested:' in line:
             next_line_contains_data[3] = True
        elif 'Memory used, Benchmark:' in line:
             next_line_contains_data[0] = True
        elif 'Memory used, Tested:' in line:
             next_line_contains_data[1] = True

# convert table to markdown for inputting into github
data['example'] = data.index
header_sep = pd.DataFrame([['---',]*len(data.columns)], columns=data.columns)

md_data = pd.concat([header_sep,data])

print(md_data.to_csv(sep="|",index=False))
