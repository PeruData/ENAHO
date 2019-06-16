###########################################################################################################
# Peruvian Households Dataset
# Author: Sebastian Sardon
# Last updated: June 16, 2019
# Retrieves raw ENAHO data from INEI's official website
# Reference period: 1997-2018 (these are all the years for which complete surveys are available)
###########################################################################################################

#import dbf
import glob
import numpy as np
import pandas as pd
import pathlib
import os
import re
import shutil
import time
import zipfile
from  simpledbf import Dbf5
from urllib.request import urlretrieve


#Codes for surveys of the class "ENAHO Metodología ACTUALIZADA"
#These are rather unstructured, so codes are obtained manually from INEI's webpage
survey_codes = {
     "enaho_1997":  "04", "enaho_1998":  "08",
     "enaho_1999":  "13", "enaho_2000":  "30",
     "enaho_2001":  "52", "enaho_2002":  "91",
     "enaho_2003":  "31", "enaho_2004": "280",
     "enaho_2005": "281", "enaho_2006": "282",
     "enaho_2007": "283", "enaho_2008": "284",
     "enaho_2009": "285", "enaho_2010": "279",
     "enaho_2011": "291", "enaho_2012": "324",
     "enaho_2013": "404", "enaho_2014": "440",
     "enaho_2015": "498", "enaho_2016": "546",
     "enaho_2017": "603", "enaho_2018": "634"
}
mod_codes = ["01","02","03","05","34","85"]

root = "/Users/Sebastian/Documents/Papers/Mines/00_Data"
os.chdir(root)
try:
    shutil.rmtree("Trash")
except:
    print("File does not exist yet")
os.mkdir("Trash")

#1. Scrap zip files
start_time = time.time()
errors = []
for yy in range(1997,2019):
    for mod_code in mod_codes:
        if yy < 2004: kind = "DBF"
        else:         kind   = "STATA"
        print("retrieving data for year {0} - module {1}".format(yy, mod_code))
        url = "http://iinei.inei.gob.pe/iinei/srienaho/descarga/{0}/{1}-Modulo{2}.zip".format(kind,survey_codes["enaho_{0}".format(yy)], mod_code)
        try:
            urlretrieve(url, "Trash/module {0} {1}.zip".format(mod_code,yy))
        except:
            if yy <2003 and mod_code == "85":
                print("module 85 not available for year {0}".format(yy))
            else:
                print("ERROR")
                errors.append(url)
print("Scrapping complete. {0} errors:".format(len(errors)))
print(errors)
ellapsed = time.time() - start_time
print("This takes {0}s".format(ellapsed))
#Around 500s  (=8 min)

#2. Extract zip files
start_time = time.time()
errors = []
for mod_code in mod_codes:
    new_dir = "Enaho/in/Raw Data/module {0}".format(mod_code)
    try:
        shutil.rmtree(new_dir)
        os.mkdir(new_dir)
    except:
        os.mkdir(new_dir)

for yy in range(1997,2019):
    for mod_code in mod_codes:
        if yy <2003 and mod_code == "85":
            print("module 85 not available for this year")
            continue
        new_dir = "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy)
        try:
            shutil.rmtree(new_dir)
            os.mkdir(new_dir)
        except:
            os.mkdir(new_dir)
        print("extracting data for module {0} - year {1}".format(mod_code, yy))

        zip_ref = zipfile.ZipFile("Trash/module {0} {1}.zip".format(mod_code, yy))
        for file_name in zip_ref.namelist():
            try:
                zip_ref.extract(file_name, "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy))
            except:
                print("could not extract {0} for year {1}".format(file_name, yy))
                errors.append(file_name)
        zip_ref.close()
print("Scrapping complete. {0} errors:".format(len(errors)))
print(errors)
ellapsed = time.time() - start_time
print("This takes {0}s".format(ellapsed))
#Around 30s (=1 min)

#3. Remove redundant enclosing folder  (only a problem for some years)
start_time = time.time()
errors = []
for yy in range(1997,2019):
    for mod_code in mod_codes:
        if yy <2003 and mod_code == "85":
            print("module 85 not available for this year")
            continue
        file_mod_yy = "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy)
        file_tree = []
        for branch in os.walk(file_mod_yy):
            file_tree.append(branch)
        if len(file_tree[0][1]) > 0: #only do this if enclosing folders exist
            for file in file_tree[1][2]: #get all the enclosed files
                file_path = file_mod_yy + "/" + file_tree[0][1][0] + "/" + file
                try:
                    shutil.move(file_path, file_mod_yy + "/" + file)
                except:
                    print("could not move {0}".format(file_path))
                errors.append(file_path)
            shutil.rmtree(file_mod_yy + "/" + file_tree[0][1][0])
print("Structuring complete. {0} errors:".format(len(errors)))
print(errors)
ellapsed = time.time() - start_time
print("This takes {0}s".format(ellapsed))
#Less than 1s (=0 min)

#4. Convert files for 1997-2003 ("ANTERIOR" class) from dbf to dta
#Exception: module 05 files for years 2001-2003 are split into two dbf files (E1)
def check_E1():
    return (mod_code=="05" and (yy == 2001 or yy == 2002 or yy == 2003))
start_time = time.time()
errors=[]
for mod_code in mod_codes:
    print("-  -  -  -  -  -  -  ")
    print(mod_code)
    for yy in range(1997,2019):
        print("----")
        print(yy)
        if yy <2003 and mod_code == "85":
            print("module 85 not available for this year")
            continue
        os.chdir(root + "/" + "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy))
        dbf_list = glob.glob("*.dbf".format(yy)) + glob.glob("*.DBF")
        if check_E1() is False:
            for file in dbf_list:
                try:
                    print("working on {0}".format(file))
                    dbf_fn = "{0}".format(file)
                    dta_fn = dbf_fn.split(".dbf")[0] + ".dta"
                    df = Dbf5(dbf_fn).to_dataframe()
                    df.columns = [column.lower() for column in df.columns]
                    df.columns = [column.replace("\x00", "") for column in df.columns]
                    df.columns = [column.replace(" ", "") for column in df.columns]
                    df.to_stata(dta_fn,      encoding = "latin1")
                    print("{0} converted to dta".format(file))
                    #os.remove(dbf_fn)
                except:
                    print("{0} bugged, must convert manually".format(file))
                    dbf_path = "module {0}/{1}".format(mod_code, yy) + dbf_fn
                    errors.append(dbf_path)
        else:
            file1 = dbf_list[0]
            file2 = dbf_list[1]
            try:
                print("working on {0} and {1}".format(file1, file2))
                dbf1_fn = "{0}".format(file1)
                dbf2_fn = "{0}".format(file2)
                dta1_fn = "{0}-1".format(yy) + ".dta"
                dta2_fn = "{0}-2".format(yy) + ".dta"
                dta_fn = "{0}".format(yy) + ".dta"
                df1 = Dbf5(dbf1_fn).to_dataframe()
                df2 = Dbf5(dbf2_fn).to_dataframe()
                for current_df,current_dta in zip([df1, df2], [dta1_fn, dta2_fn]):
                        print("{0}".format(current_df))
                        print("{0}".format(current_dta))
                        current_df.columns = [column.lower() for column in current_df.columns]
                        current_df.columns = [column.replace("\x00", "") for column in current_df.columns]
                        current_df.columns = [column.replace(" ", "") for column in current_df.columns]
                        current_df.to_stata(current_dta,      encoding = "latin1")
                merge_vars = ["conglome","vivienda","hogar","codperso"]
                df = df1.merge(df2, on = merge_vars)
                df.to_stata(dta_fn, encoding = "latin1")
                print("{0} converted to dta".format(current_df))
                #os.remove(dbf_fn)
            except:
                print("{0} bugged, must convert manually".format())
                dbf_path = "module {0}/{1}".format(mod_code, yy) + dbf_fn
                errors.append(dbf_path)
print("Data conversion complete. {0} errors:".format(len(errors)))
print(errors)
ellapsed = time.time() - start_time
print("This takes {0}s".format(ellapsed))
#380s (=6 min)

#5. Rename dta files for ease of looping
start_time = time.time()
errors=[]
for mod_code in mod_codes:
    for yy in range(1997,2019):
        if mod_code == "85": #we deal with files from this module in a special way: convert the "yy-1" dataset
            if yy<2003:
                print("module 85 not available for this year")
                continue
            else:
                os.chdir(root + "/" + "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy))
                dta_files = glob.glob("*{0}-1.dta".format(yy))
                print(dta_files)
                os.rename(dta_files[0],"{0}.dta".format(yy))
        else: #general criterion: rename (for use in Stata) the biggest file, ignore others
            print("doing mod {0} - year {1}".format(mod_code, yy))
            os.chdir(root + "/" + "Enaho/in/Raw Data/module {0}/{1}".format(mod_code, yy))
            dta_files = glob.glob("*.dta") + glob.glob("*.DTA")
            sizes = [os.path.getsize(file) for file in dta_files]
            index_max = np.argmax(sizes)
            os.rename(dta_files[index_max],"{0}.dta".format(yy))
print("Renames complete. {0} errors:".format(len(errors))) #See Section 2
ellapsed = time.time() - start_time
print("This takes {0}s".format(ellapsed))
#Less than 1s

#6 Take out the Trash
for yy in range(1997,2019):
    for mod_code in mod_codes:
        zip_file = "Trash/module {0} {1}.zip".format(mod_code, yy)
os.remove(zip_file)
