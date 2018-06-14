# Loading Libraries
import pandas as pd
import numpy as np

# Loading Dataset
datapath = r'DMEFExtractSummaryV01.CSV'
data = pd.read_csv(datapath)

data['FirstYYMM'] = data['FirstYYMM'].astype(str).add('15').astype(np.int64)
data['AcqDate'] = data['AcqDate'].astype(str).add('15').astype(np.int64)


data.to_csv('cleaned_summary.csv', index = False)
    
