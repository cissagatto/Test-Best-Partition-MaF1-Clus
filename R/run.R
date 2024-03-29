##############################################################################
# TEST BEST PARTITION MACRO-F1 CLUS                                          #
# Copyright (C) 2021                                                         #
#                                                                            #
# This code is free software: you can redistribute it and/or modify it under #
# the terms of the GNU General Public License as published by the Free       #
# Software Foundation, either version 3 of the License, or (at your option)  #
# any later version. This code is distributed in the hope that it will be    #
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General   #
# Public License for more details.                                           #
#                                                                            #
# Elaine Cecilia Gatto | Prof. Dr. Ricardo Cerri | Prof. Dr. Mauri           #
# Ferrandin | Federal University of Sao Carlos                               #
# (UFSCar: https://www2.ufscar.br/) Campus Sao Carlos | Computer Department  #
# (DC: https://site.dc.ufscar.br/) | Program of Post Graduation in Computer  #
# Science (PPG-CC: http://ppgcc.dc.ufscar.br/) | Bioinformatics and Machine  #
# Learning Group (BIOMAL: http://www.biomal.ufscar.br/)                      #
#                                                                            #
##############################################################################


###########################################################################
#
###########################################################################
FolderRoot = "~/Test-Best-Partition-MaF1-Clus"
FolderScripts = "~/Test-Best-Partition-MaF1-Clus/R"



##################################################################################################
# Runs for all datasets listed in the "datasets.csv" file                                        #
# n_dataset: number of the dataset in the "datasets.csv"                                         #
# number_cores: number of cores to paralell                                                      #
# number_folds: number of folds for cross validation                                             #
# delete: if you want, or not, to delete all folders and files generated                         #
##################################################################################################
executeTBPMA <- function(ds,
                         dataset_name,
                         number_dataset, 
                         number_cores, 
                         number_folds, 
                         similarity,
                         folderResults){
  
  FolderRoot = "~/Test-Best-Partition-MaF1-Clus"
  FolderScripts = "~/Test-Best-Partition-MaF1-Clus/R"
  
  setwd(FolderScripts)
  source("clusTest.R")

  diretorios <- directories(dataset_name, folderResults, similarity)
  
  if(number_cores == 0){
    
    cat("\n\n##########################################################")
    cat("\n# Zero is a disallowed value for number_cores. Please      #")
    cat("\n# choose a value greater than or equal to 1.               #")
    cat("\n############################################################\n\n")
    
  } else {
    
    cl <- parallel::makeCluster(number_cores)
    doParallel::registerDoParallel(cl)
    print(cl)
    
    if(number_cores==1){
      cat("\n\n##########################################################")
      cat("\n# Running Sequentially!                                    #")
      cat("\n############################################################\n\n")
    } else {
      cat("\n\n############################################################")
      cat("\n# Running in parallel with ", number_cores, " cores!         #")
      cat("\n##############################################################\n\n")
    }
  }
  cl = cl
  
  retorno = list()
  
  
  cat("\n\n##########################################################")
  cat("\n# RUN: get labels                                          #")
  cat("\n############################################################\n\n")
  arquivo = paste(diretorios$folderNamesLabels, "/" ,
                  dataset_name, "-NamesLabels.csv", sep="")
  namesLabels = data.frame(read.csv(arquivo))
  colnames(namesLabels) = c("id", "labels")
  namesLabels = c(namesLabels$labels)

  
  cat("\n\n##########################################################")
  cat("\n# Run: Get the label space                                 #")
  cat("\n############################################################\n\n")
  timeLabelSpace = system.time(resLS <- labelSpace(ds, 
                                                   dataset_name, 
                                                   number_folds, 
                                                   folderResults))
  
  
  cat("\n\n##########################################################")
  cat("\n# RUN TEST: build and test partitions                      #")
  cat("\n############################################################\n\n")
  timeBuild = system.time(resTHP <- buildAndTest(ds,
                                                 dataset_name,
                                                 number_dataset, 
                                                 number_cores, 
                                                 number_folds,
                                                 namesLabels,
                                                 resLS,
                                                 similarity,
                                                 folderResults))

  
  cat("\n\n##########################################################")
  cat("\n# RUN TEST: Matrix Confusion                                #")
  cat("\n############################################################\n\n")
  timeSplit = system.time(resGather <- juntaResultadosTEST(ds,
                                                           dataset_name,
                                                           number_dataset, 
                                                           number_cores, 
                                                           number_folds,
                                                           namesLabels,
                                                           resLS,
                                                           similarity,
                                                           folderResults))

  
  cat("\n\n##########################################################")
  cat("\n# RUN TEST: Evaluation Fold                                #")
  cat("\n############################################################\n\n")
  timeAvalia = system.time(resEval <- avaliaTest(ds,
                                                 dataset_name,
                                                 number_dataset, 
                                                 number_cores, 
                                                 number_folds,
                                                 namesLabels,
                                                 resLS,
                                                 similarity,
                                                 folderResults))

  
  cat("\n\n##########################################################")
  cat("\n# RUN TEST: Gather Evaluation                                #")
  cat("\n############################################################\n\n")
  timeGather = system.time(resGE <- juntaAvaliacoesTest(ds,
                                                        dataset_name,
                                                        number_dataset, 
                                                        number_cores, 
                                                        number_folds,
                                                        namesLabels,
                                                        resLS,
                                                        similarity,
                                                        folderResults))

  
  cat("\n\n##########################################################")
  cat("\n# RUN: Save Runtime                                        #")
  cat("\n############################################################\n\n")
  timesExecute = rbind(timeLabelSpace, timeBuild, timeSplit,
                       timeAvalia, timeGather)
  setwd(diretorios$folderRS)
  write.csv(timesExecute, paste(dataset_name, 
                                "-executeTBPMI-RunTime.csv", sep=""))

  

  cat("\n\n##########################################################")
  cat("\n# RUN: Stop Parallel                                       #")
  cat("\n############################################################\n\n")
  parallel::stopCluster(cl) 	
  
  
  gc()
  cat("\n\n##########################################################")
  cat("\n# RUN: END                                                 #")
  cat("\n############################################################\n\n")

  gc()
}

##################################################################################################
# Please, any errors, contact us: elainececiliagatto@gmail.com                                   #
# Thank you very much!                                                                           #
##################################################################################################
