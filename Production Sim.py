#!/usr/bin/env python
# coding: utf-8

# # Production Simulation 

# In[11]:


from dataclasses import dataclass
import numpy_financial as npf
@dataclass
class ModelInputs:
    n_phones: float = 100000
    price_scrap: float = 50000
    price_phone: float = 500
    cost_machine_adv: float = 1000000
    cogs_phone: float = 250
    n_life: int = 10
    n_machines: int = 5
    d_1: float = 100000
    g_d: float = 0.2
    max_year: float = 20
    interest: float = 0.05
    # Inputs for bonus problem
    elasticity: float = 100
    demand_constant: float = 300000
        
d = ModelInputs()
d


# In[10]:


# Initial values
cur_ads = 0
machines_info = []  # List to store information about purchased machines (year purchased, remaining years)
mach_years = 0
n_advert = 0
cur_machines = 0
max_capacity = 5  # Maximum capacity for machines
purchased_machines = set()  # Set to store machine IDs that have already been purchased
machines_trend = 0
yearly_NI_list = []
negative_ni_occurred = False  # Flag to track the first occurrence of negative yearly_NI

def c_ads(prior_ads=0, cur_ads=0, cur_machines = 0):
    cur_ads = prior_ads
    """
     Increments # of adverts (prior_ads=0, cur_ads=0, cur_machines = 0)
    """
    if y_demand() <= (cur_machines*d.n_phones) and cur_machines > d.n_machines:
        cur_ads +=1
    else:
        cur_ads = prior_ads
    return cur_ads
def c_ads_machines(prior_ads=0, prior_machines=0, increment_by=1):
    """
    Increments # of adverts and machines
    (prior_ads=0, prior_machines=0, increment_by=1)
    """
    cur_machines = min(prior_machines + increment_by, 5)  # Limit cur_machines to a maximum of 5

    cur_ads = prior_ads + 1 if (cur_machines - prior_machines) == 0 else prior_ads + 0  # Increment cur_ads if cur_machines is not incrementing

    return cur_ads, cur_machines
def y_demand(a=n_advert, b=d.d_1, c=d.g_d):
    """
    Returns year of demand after advert (a=d.d_1, b=n_advert, c=d.g_d):
    """
    year_demand = npf.fv(c, a, 0, -b)
    return year_demand

# Loop over years
for year in range(1, d.max_year + 1):
    # Increment machine years for each machine
    for machine in machines_info:
        machine['remaining_years'] -= 1
    
    # Remove machines that have expired
    machines_info = [machine for machine in machines_info if machine['remaining_years'] > 0]
    
    # Check if a new machine is purchased
    cur_ads, cur_machines = c_ads_machines(prior_ads=cur_ads, prior_machines=cur_machines, increment_by=1)
    
    # Add information about the new machine (year purchased, remaining years)
    if cur_machines > len(machines_info) and len(machines_info) < max_capacity:
        machine_id = len(machines_info) + 1  # Assign a unique ID to each machine
        if machine_id not in purchased_machines:
            machines_info.append({'machine_id': machine_id, 'year_purchased': year, 'remaining_years': 10})
            purchased_machines.add(machine_id)

    # Handle dropping off machines after 10 years
    machines_to_remove = [machine for machine in machines_info if machine['remaining_years'] == 0]
    for machine in machines_to_remove:
        purchased_machines.remove(machine['machine_id'])
        machines_info.remove(machine)

    # yearly output
    yearly_output = len(machines_info) * d.n_phones  # Limit output to cur_machines
    
    # Min vs output and demand
    min_phones = min(yearly_output, y_demand(cur_ads))
   
    # Check if len(machines_info) is increasing or decreasing
   
    if len(machines_info) < cur_machines and len(machines_info) >= 1:
        machines_trend = 1  
    else:
        machines_trend = 0  # No trend
   
    # Net income
    yearly_revenue = min_phones * d.price_phone
    yearly_cost = min_phones * d.cogs_phone
    yearly_profit = yearly_revenue - yearly_cost
    yearly_NI = yearly_profit - d.cost_machine_adv + (machines_trend*d.price_scrap)
    
    yearly_NI_list.append(yearly_NI)
    NPV = npf.npv(d.interest, yearly_NI_list)
    
    if yearly_NI < 0 and not negative_ni_occurred:
        yearly_NI += d.price_scrap
        negative_ni_occurred = True

    print(f"Year {year}: Machines: {len(machines_info)} Ads: {cur_ads} Cash_Flow: ${yearly_NI:.0f} NPV: ${NPV:.0f}")

