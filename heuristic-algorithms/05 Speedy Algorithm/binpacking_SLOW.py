# -*- coding: utf-8 -*-
"""
Created on Thu Mar 22 17:23:53 2018

@author: Jamee
"""

def binpack(articles,bin_cap):

    my_team_number_or_name = "jmallen01"
    bin_contents = []

    a_list = [[k,v] for k,v in articles.items()]
    a_list.sort(key=lambda x:x[1], reverse=True)    
    used = []    
    
    for j in range(len(a_list)):
        current_bin = 0
        contents = []
        for i in range(len(a_list)):
            if a_list[i][1] + current_bin <= bin_cap and a_list[i][0] not in used:
                current_bin += a_list[i][1]
                contents.append(a_list[i][0])
                used.append(a_list[i][0])
        bin_contents.append(contents)
    
    return my_team_number_or_name, bin_contents 