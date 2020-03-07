# -*- coding: utf-8 -*-
"""
Created on Tue Apr 17 15:34:23 2018

@author: Jamee
"""

def binpack(articles,bin_cap):
    my_team_number_or_name = "2-11"
    bin_contents = []
    
    a_list = [[k,v] for k,v in articles.items()]
    a_list.sort(key=lambda x:x[1], reverse=True)

    def newBin():
        return [[], 0.0]

    for a in a_list:
        added = False
        for thisBin in bin_contents:
            if a[1] + thisBin[1] <= bin_cap:
                thisBin[0].append(a[0])
                thisBin[1] += a[1]
                added = True
                break
        if not added:
            thisBin = newBin()
            thisBin[0].append(a[0])
            thisBin[1] += a[1]
            bin_contents.append(thisBin)

    for i in range(len(bin_contents)):
        bin_contents[i] = [k for k in bin_contents[i][0]]

    return my_team_number_or_name, bin_contents