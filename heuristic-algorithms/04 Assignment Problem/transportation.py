# -*- coding: utf-8 -*-
"""
Created on Wed Apr 04 11:02:06 2018

@author: Jamee
"""

def trans(dist, dcs, stores_vol):
    
    my_team_or_name = "jmallen01"
    result = []
    
    #dcs: volume, num doors, num drivers
    
    store_list = []
    dc_cap = [0] * len(dcs.keys())
    door_cap = [0] * len(dcs.keys())
    stores_vol = dict(stores_vol)
    
#    stores_vol = [[1, 1000], [2,1500], [3, 1000], [4,1200]]
#    dcs = {0: (2000, 2, 20), 1:(6000, 3, 30)}
#    dist = {(0,1): 10, (0, 2):5, (0, 3):20, (0,4):50, (1,1):40, (1,2):30, (1,3):60, (1,4):100}
    
    trans_list = [[k,v] for k,v in dist.items()]
    trans_list.sort(key=lambda x:x[1]) 

    
    for i in range(len(trans_list)):
        if trans_list[i][0][1] not in store_list:
            if stores_vol[trans_list[i][0][1]] <= (dcs[trans_list[i][0][0]][0] - dc_cap[trans_list[i][0][0]]):
                if door_cap[trans_list[i][0][0]] <= dcs[trans_list[i][0][0]][1]:
                    if (dc_cap[trans_list[i][0][0]] + stores_vol[trans_list[i][0][1]]) / 4000 <= dcs[trans_list[i][0][0]][2]: 
                        store_list.append(trans_list[i][0][1])
                        result.append((trans_list[i][0][1],trans_list[i][0][0]))
                        dc_cap[trans_list[i][0][0]] += stores_vol[trans_list[i][0][1]]
                        door_cap[trans_list[i][0][0]] += 1
              
    return my_team_or_name, result