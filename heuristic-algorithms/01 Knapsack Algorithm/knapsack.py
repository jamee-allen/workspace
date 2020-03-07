# -*- coding: utf-8 -*-
"""
Created on Wed Mar 14 18:48:02 2018

@author: Jamee
"""

def load_knapsack(things,knapsack_cap):
    """ You write your heuristic knapsack algorithm in this function using the argument values that are passed
             items: is a dictionary of the items no yet loaded into the knapsack
             knapsack_cap: the capacity of the knapsack (volume)
    
        Your algorithm must return two values as indicated in the return statement:
             my_team_number_or_name: if this is a team assignment then set this variable equal to an integer representing your team number;
                                     if this is an indivdual assignment then set this variable to a string with you name
            items_to_pack: this is a list containing keys (integers) of the items you want to include in the knapsack
                           The integers refer to keys in the items dictionary. 
   """        
    my_team_number_or_name = "jmallen01"
    items_to_pack = []
    volume = 0.0
    value = 0.0
    items_to_pack = []
    item_list = [[k,v] for k,v in things.items()]
    l = lambda x:x[1][1]
    item_list.sort(key=l, reverse=True)
    for i in range(len(item_list)):
        if item_list[i][1][0] < (knapsack_cap - volume):
            items_to_pack.append(item_list[i][0])
            volume += item_list[i][1][0]
            value += item_list[i][1][1]            
    return my_team_number_or_name, items_to_pack