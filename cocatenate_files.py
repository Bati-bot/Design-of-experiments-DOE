import os
import pandas as pd
import numpy as np

base_path = os.path.dirname(os.path.abspath(__file__))
files = ["2019-Oct", "2019-Nov", "2019-Dec", "2020-Jan", "2020-Feb"]
df_complete = pd.DataFrame()

for f in files:
    this_df = pd.read_csv(f"{base_path}/Data/{f}.csv")
    df_complete = pd.concat([df_complete, this_df])

df_complete['time'] = pd.to_datetime(df_complete['event_time'])
df_complete['date'] = df_complete['time'].dt.date
df_complete["sales"] = np.where(df_complete["event_type"]=="purchase", df_complete["price"], 0)
df_complete = pd.get_dummies(data=df_complete, columns=["event_type"])

df_complete.to_csv(f"{base_path}/Data/events_complete.csv", index=False)
