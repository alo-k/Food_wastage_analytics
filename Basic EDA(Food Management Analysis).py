#!/usr/bin/env python
# coding: utf-8

# In[2]:


import pandas as pd


# In[3]:


import numpy as np


# In[4]:


import seaborn as sns


# In[16]:


df1 = pd.read_csv("providers_data.csv")


# In[17]:


df1.head()


# In[18]:


df1.columns.tolist()


# In[25]:


df1.columns = df1.columns.str.lower()


# In[26]:


df1.info()


# In[27]:


df1.head()


# In[29]:


df2 = pd.read_csv("receivers_data.csv")


# In[30]:


df2.head()


# In[33]:


df2.columns.tolist()


# In[34]:


df2.columns = df2.columns.str.lower()


# In[35]:


df2.info()


# In[36]:


df2.head()


# In[38]:


df3 = pd.read_csv("food_listings_data.csv")


# In[39]:


df3.head()


# In[40]:


df3.columns.tolist()


# In[41]:


df3.columns = df3.columns.str.lower()


# In[42]:


df3.info()


# In[43]:


df3.head()


# In[44]:


df4 = pd.read_csv("claims_data.csv")


# In[45]:


df4.head()


# In[46]:


df4.columns.tolist()


# In[47]:


df4.columns = df4.columns.str.lower()


# In[48]:


df4.columns


# In[49]:


df4.head()


# df4.info()

# In[50]:


df4.info()


# In[53]:


from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@LAPTOP-1BMVNR2V/Food_Waste_Analysis?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server"
)

df1.to_sql(
    name="providers_data", 
    con=engine,
    if_exists="replace",
    index=False
)


# In[55]:


from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@LAPTOP-1BMVNR2V/Food_Waste_Analysis?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server"
)

df2.to_sql(
    name="receivers_data", 
    con=engine,
    if_exists="replace",
    index=False
)


# In[57]:


from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@LAPTOP-1BMVNR2V/Food_Waste_Analysis?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server"
)

df3.to_sql(
    name="food_listings_data", 
    con=engine,
    if_exists="replace",
    index=False
)


# In[59]:


from sqlalchemy import create_engine

engine = create_engine(
    "mssql+pyodbc://@LAPTOP-1BMVNR2V/Food_Waste_Analysis?trusted_connection=yes&driver=ODBC+Driver+17+for+SQL+Server"
)

df4.to_sql(
    name="claims_data", 
    con=engine,
    if_exists="replace",
    index=False
)

