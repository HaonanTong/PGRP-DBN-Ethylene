import pandas as pd 

db = pd.read_csv('DB6.csv', index_col = 'id')

# ----------------------------------------------------------------
# Expression level of nTFs which are responsive to ethylene
# ----------------------------------------------------------------
for atp in range(1,7):
    db_sub = db[(db['ATP']==atp) & (db['TF']==0) & (db['ethylene']==1)]
    db_sub = db_sub.loc[:,'kat_1_1':'kat_3_7']
    # print len(db_sub)
    db_sub.to_csv('TnTFs'+'/Ethylene-nTFs-DEGs-time-Activation'+str(atp)+'.csv')

# ----------------------------------------------------------------
# Expression level of nTFs which are responsive to ethylene
# ----------------------------------------------------------------
for atp in range(1,7):
    db_sub = db[(db['ATP']==atp) & (db['TF']==1) & (db['ethylene']==1)]
    db_sub = db_sub.loc[:,'kat_1_1':'kat_3_7']
    # print len(db_sub)
    db_sub.to_csv('TTFs'+'/Ethylene-TFs-DEGs-time-Activation'+str(atp)+'.csv')