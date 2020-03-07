# -*- coding: utf-8 -*-
"""
Created on Wed Mar 28 14:38:51 2018

@author: Jamee
"""

def mst_algo(locs,dist):
    name_or_team = "jmallen01"
    
    mst = []
    dist_list = [[k,v] for k,v in dist.items()]
    dist_list.sort(key=lambda x:x[1]) 
    mst.append(dist_list[0][0])
    
    a = [x[0] for x in dist.keys()]
    b = [x[1] for x in dist.keys()]
    c = a +b
    d = list(set(c))
    
    def uniquevalues(d, mst):
        e = [[x,y] for x,y in mst]
        check = []
        for pair in e:
            check = check + pair
        if not set(d).issubset(set(check)):
            return False
        else:
            return True
    
    
    def cycle_exists(G):                       
        marked = { u : False for u in G }    
        found_cycle = [False]              
                                              
                                             
        for u in G:
            if not marked[u]:
                dfs_visit(G, u, found_cycle, u, marked) 
            if found_cycle[0]:
                break
        return found_cycle[0]
     
     
    def dfs_visit(G, u, found_cycle, pred_node, marked):
        if found_cycle[0]:     
            return
        marked[u] = True               
        for v in G[u]:                                   
            if marked[v] and v != pred_node:              
                found_cycle[0] = True  
                return
            if not marked[v]:
                dfs_visit(G, v, found_cycle, u, marked)
    
    f = 1
    while uniquevalues(d, mst) == False:
        mst.append(dist_list[f][0])
        new_dict = {}
        
        for x in mst:
            new_dict[x[0]] = []
            new_dict[x[1]] = []
        
        for x in mst:
            new_dict[x[0]].append(x[1])
        
        for x in mst:
            new_dict[x[1]].append(x[0])
        
        if cycle_exists(new_dict) == True:
            del(mst[-1])
        
        f+=1
        
    
    return name_or_team, mst


"""
Source used: https://algocoding.wordpress.com/2015/04/02/detecting-cycles-in-an-undirected-graph-with-dfs-python/
"""