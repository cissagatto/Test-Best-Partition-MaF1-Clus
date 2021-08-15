cat("\n\n################################################################################################")
cat("\n# START TEST THE BEST PARTITION WITH CLUS                                                        #")
cat("\n##################################################################################################\n\n")

##################################################################################################
# Test the Best Partition with CLUS                                                              #
# Copyright (C) 2021                                                                             #
# VERSION WITH TRAIN PLUS VALIDATION                                                             #
#                                                                                                #
# This code is free software: you can redistribute it and/or modify it under the terms of the    #
# GNU General Public License as published by the Free Software Foundation, either version 3 of   #
# the License, or (at your option) any later version. This code is distributed in the hope       #
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of         #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for    #
# more details.                                                                                  #
#                                                                                                #
# Elaine Cecilia Gatto | Prof. Dr. Ricardo Cerri | Prof. Dr. Mauri Ferrandin                     #
# Federal University of Sao Carlos (UFSCar: https://www2.ufscar.br/) Campus Sao Carlos           #
# Computer Department (DC: https://site.dc.ufscar.br/)                                           #
# Program of Post Graduation in Computer Science (PPG-CC: http://ppgcc.dc.ufscar.br/)            #
# Bioinformatics and Machine Learning Group (BIOMAL: http://www.biomal.ufscar.br/)               #
#                                                                                                #
##################################################################################################

##################################################################################################
# Script 1 - Libraries                                                                           #
##################################################################################################

##################################################################################################
# Configures the workspace according to the operating system                                     #
##################################################################################################
sistema = c(Sys.info())
FolderRoot = ""
if (sistema[1] == "Linux"){
  FolderRoot = paste("/home/", sistema[7], "/Test-Best-Partition-MacroF1-TVT", sep="")
} else {
  FolderRoot = paste("C:/Users/", sistema[7], "/Test-Best-Partition-MacroF1-TVT", sep="")
}
FolderScripts = paste(FolderRoot, "/scripts/", sep="")



##################################################################################################
# Options Configuration                                                                          #
##################################################################################################
options(java.parameters = "-Xmx32g")
options(show.error.messages = TRUE)
options(scipen=30)


##################################################################################################
# Read the dataset file with the information for each dataset                                    #
##################################################################################################
setwd(FolderRoot)
datasets <- data.frame(read.csv("datasets.csv"))



##################################################################################################
# ARGS COMMAND LINE                                                                              #
##################################################################################################
cat("\nGet Args")
args <- commandArgs(TRUE)



##################################################################################################
# Get dataset information                                                                        #
##################################################################################################
ds <- datasets[args[1],]


##################################################################################################
# Get dataset information                                                                        #
##################################################################################################
number_dataset <- as.numeric(args[1])
cat("\nTBPC \t number_dataset: ", number_dataset)



##################################################################################################
# Get the number of cores                                                                        #
##################################################################################################
number_cores <- as.numeric(args[2])
cat("\nTBPC \t cores: ", number_cores)



##################################################################################################
# Get the number of folds                                                                        #
##################################################################################################
number_folds <- as.numeric(args[3])
cat("\nTBPC \t folds: ", number_folds)



##################################################################################################
# Get the number of folds                                                                        #
##################################################################################################
folderResults <- toString(args[4])
cat("\nTBPC \t  folder: ", folderResults)



##################################################################################################
# Get dataset name                                                                               #
##################################################################################################
dataset_name <- toString(ds$Name)
cat("\nTBPC \t nome: ", dataset_name)



##################################################################################################
# DON'T RUN -- it's only for test the code
# ds <- datasets[29,]
# dataset_name = ds$Name
# number_dataset = ds$Id
# number_cores = 10
# number_folds = 10
# folderResults = "/dev/shm/res"
##################################################################################################


##################################################################################################
#cat("\n\nCopy FROM google drive \n")
#destino = paste(FolderRoot, "/datasets/", dataset_name, sep="")
#origem = paste("cloud:/Datasets/CrossValidation_WithValidation/", dataset_name, sep="")
#comando = paste("rclone -v copy ", origem, " ", destino, sep="")
#cat("\n", comando, "\n\n")
#print(system(comando))


##################################################################################################
cat("\nCreate Folder")
if(dir.exists(folderResults)==FALSE){
  dir.create(folderResults)
}


##################################################################################################
# LOAD RUN.R                                                                                     #
##################################################################################################
setwd(FolderScripts)
source("run.R")


##################################################################################################
# GET THE DIRECTORIES                                                                            #
##################################################################################################
cat("\nGet directories\n")
diretorios <- directories(dataset_name, folderResults)


########################################################################################################################
#cat("\n Copy partitions from google drive")
#destino = paste(diretorios$folderBestPartitions, "/", dataset_name, sep="")
#origem = paste("cloud:[2021]ResultadosExperimentos/Best-Partitions/HPML-J/Macro-F1/", dataset_name, sep="")
#comando1 = paste("rclone -v copy ", origem, " ", destino, sep="")
#cat("\n", comando1, "\n\n")
#print(system(comando1))


##################################################################################################
# execute the code and get the total execution time                                              #
# n_dataset, number_cores, number_folds, folderResults                                           #
##################################################################################################
timeFinal <- system.time(results <- executeTBPC (args[1], number_cores, number_folds, folderResults))
print(timeFinal)

# DO NOT RUN ONLY FOR TEST
# timeFinal <- system.time(results <- executeTBPC(2, number_cores, number_folds, folderResults))


Folder = paste(diretorios$folderDatasetResults, "/", dataset_name, sep="")
if(dir.exists(Folder)==FALSE){
  dir.create(Folder)
}


##################################################################################################
# save the total time in rds format in the dataset folder                                        #
##################################################################################################
cat("\nSave Rds\n")
str0 <- paste(diretorios$folderResultsDataset, "/", dataset_name, "-results-tbpc.rds", sep="")
cat("\n", str0, "\n\n")
save(results, file = str0)


##################################################################################################
# save results in RDATA form in the dataset folder                                               #
##################################################################################################
cat("\nSave Rdata \n")
str1 <- paste(diretorios$folderResultsDataset, "/", dataset_name, "-results-tbpc.RData", sep="")
cat("\n", str1, "\n\n")
save(results, file = str1)


##################################################################################################
# compress the results for later transfer to the dataset folder                                  #
##################################################################################################
cat("\nCompress results \n")
setwd(diretorios$folderResultsDataset)
str3 = paste("tar -zcvf ", dataset_name, "-results-tbpc.tar.gz ", diretorios$folderResults, sep="")
cat("\n", str3, "\n\n")
print(system(str3))


##################################################################################################
# copy file                                                                                      #
##################################################################################################
cat("\nCopy file tar \n")
str4 = paste("cp ", diretorios$folderResultsDataset, "/", dataset_name, "-results-tbpc.tar.gz ", Folder, sep="")
cat("\n", str4, "\n\n")
print(system(str4))


########################################################################################################################
#cat("\n Copy Results to google drive")
#destino = paste("cloud:[2021]ResultadosExperimentos/Test-Best-Partitions/HPML-J/Macro-F1/", dataset_name, sep="")
#comando3 = paste("rclone -v copy ", Folder, " ", destino, sep="")
#cat("\n", comando3, "\n\n")
#print(system(comando3))


##################################################################################################
#cat("\nDelete folder results temporary \n")
#str5 = paste("rm -r ", diretorios$folderResults, sep="")
#cat("\n", str5, "\n\n")
#print(system(str5))


##################################################################################################
#cat("\nDelete folder specific dataset \n")
#str7 = paste("rm -r ", diretorios$folderSpecificDataset, sep="")
#cat("\n", str7, "\n\n")
#print(system(str7))


##################################################################################################
#cat("\nDelete folder partitions \n")
#str8 = paste("rm -r ", diretorios$folderBestPartitions, "/", dataset_name, sep="")
#cat("\n", str8, "\n\n")
#print(system(str7))


rm(list = ls())

gc()

cat("\n##################################################################################################")
cat("\n# END OF TEST BEST PARTITION MACRO F1. THANKS GOD !                                               #")
cat("\n##################################################################################################")
cat("\n\n\n\n")

if(interactive()==TRUE){ flush.console() }

##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
##################################################################################################
