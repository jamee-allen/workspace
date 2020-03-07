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
    
    
    def cycle_exists(G):                      # - G is an undirected graph.              
        marked = { u : False for u in G }     # - All nodes are initially unmarked.
        found_cycle = [False]                 # - Define found_cycle as a list so we can change
                                              # its value per reference, see:
                                              # http://stackoverflow.com/questions/11222440/python-variable-reference-assignment
     
        for u in G:                           # - Visit all nodes.
            if not marked[u]:
                dfs_visit(G, u, found_cycle, u, marked)     # - u is its own predecessor initially
            if found_cycle[0]:
                break
        return found_cycle[0]
     
     
    def dfs_visit(G, u, found_cycle, pred_node, marked):
        if found_cycle[0]:                                # - Stop dfs if cycle is found.
            return
        marked[u] = True                                  # - Mark node.
        for v in G[u]:                                    # - Check neighbors, where G[u] is the adjacency list of u.
            if marked[v] and v != pred_node:              # - If neighbor is marked and not predecessor,
                found_cycle[0] = True                     # then a cycle exists.
                return
            if not marked[v]:                             # - Call dfs_visit recursively.
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