# -*- coding: utf-8 -*-
"""
Created on Thu Mar 15 16:50:29 2018

@author: kmcke
"""

def load_knapsack(things,knapsack_cap):

    my_team_number_or_name="jmallen01"
    
    def bestvalue(i, j):
        if i == 0: return 0
        weight, value = things.values()[i - 1]
        if weight > j:
            return bestvalue(i - 1, j)
        else:
            return max(bestvalue(i - 1, j),
                       bestvalue(i - 1, j - weight) + value)
            
    kc = knapsack_cap
    items_to_pack = []
    for i in xrange(len(things), 0, -1):
        if bestvalue(i, kc) != bestvalue(i - 1, kc):
            items_to_pack.append(things.items()[i-1][0])
            kc -= things.values()[i - 1][0]
            
    items_to_pack.reverse()  
    return my_team_number_or_name,items_to_pack

#made with help from www.personal.kent.edu/~rmuhamma/Algorithms/MyAlgorithms/Dynamic/knapsackdyn.htm