###########################################################################################################
# Peruvian Households Dataset
# SSB
# Last updated: July 26, 2018
# I obtain raw data from the ENAHO survey from INEI's official webpage
# Reference period: 2004-2017 (these are all the years for which the survey with an "updated" methodology is available)
###########################################################################################################
import glob
import pathlib
import os
import shutil
import zipfile
from urllib.request import urlretrieve


#Codes for surveys of the class "ENAHO Metodología ACTUALIZADA"
#These are rather unstructured, so codes are obtained manually from INEI's webpage
survey_codes = {
     "enaho_2004": "280", "enaho_2005": "281",
     "enaho_2006": "282", "enaho_2007": "283",
     "enaho_2008": "284", "enaho_2009": "285",
     "enaho_2010": "279", "enaho_2011": "291",
     "enaho_2012": "324", "enaho_2013": "404",
     "enaho_2014": "440", "enaho_2015": "498",
     "enaho_2016": "546", "enaho_2017": "603",
}

os.chdir("/Users/Sebastian/Documents/Papers/Mines SSB/00_Data/Enaho")

#Scrap zip files
mod_code = "05"
for yy in range(2004,2018):
    print("retrieving data for year {0}".format(yy))
    url = "http://iinei.inei.gob.pe/iinei/srienaho/descarga/STATA/{0}-Modulo{1}.zip".format(survey_codes["enaho_{0}".format(yy)], mod_code)
    print(url)
    urlretrieve(url, "Trash/module {1} {0}.zip".format(yy, mod_code))
    print("DONE")

#Extract zip files
for yy in range(2004,2018):
    print("extracting data for year {0}".format(yy))
    zip_ref = zipfile.ZipFile("Trash/module {1} {0}.zip".format(yy, mod_code))
    try:
        shutil.rmtree("in/Raw Data/module {1}/{0}".format(yy, mod_code))
        os.mkdir("in/Raw Data/module {1}/{0}".format(yy, mod_code))
    except:
        os.mkdir("in/Raw Data/module {1}/{0}".format(yy, mod_code))

    for file_name in zip_ref.namelist():
        try:
            zip_ref.extract(file_name, "in/Raw Data/module {1}/{0}".format(yy, mod_code))
        except:
            print("could not extract {1} for year {0}".format(yy, file_name))
    zip_ref.close()
    print("DONE")

#Remove intermediate files (only a problem for some years)
for yy in range(2004,2018):
    file_yy = "in/Raw Data/module {1}/{0}".format(yy, mod_code)
    file_tree = []
    for branch in os.walk(file_yy):
        file_tree.append(branch)
    if len(file_tree[0][1]) > 0:
        for file in file_tree[1][2]:
            file_path = file_yy + "/" + file_tree[0][1][0] + "/" + file
            shutil.move(file_path, file_yy + "/" + file)
        shutil.rmtree(file_yy + "/" + file_tree[0][1][0])
print("TREE DONE")
#Rename dta files for ease of looping
for yy in range(2004,2018):
    file_yy = "in/Raw Data/module {1}/{0}".format(yy, mod_code)
    os.chdir("/Users/Sebastian/Documents/Papers/Mines SSB/00_Data/Enaho" + "/" + file_yy)
    dta_files = glob.glob("*500.dta".format(yy))
    os.rename(dta_files[0],"{0}.dta".format(yy))
