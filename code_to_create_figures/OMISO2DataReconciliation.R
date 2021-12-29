
#------------------------------------
#' Program name: OMISO2DataReconciliation.R
#'@param command API command to execute
#'@param ... other optional parameters, depending on command
#'@details Program purpose: Process OMI SO2 emissions data and get corresponding data points for each year for a given range of kms.Basically aggregates data from other sources within a specified range and merges the same with the OMI.
#'Input: OMI data file, EIA data file, distance file (with coordinates)
#'parameters: Specified in notes below for each function
#'Output: Consolidated OMI file with point data, error statistics, updated distance matrix
#'Required libraries: geosphere,dplyr,magrittr
#'Notes: Structured as a set of 4 functions, 2 to process the distance matrices, 1 to combine OMI data
#'       and other dataset and final function to produce consolidated data
#'@author KBN August 2019
#'@import dplyr
#'@import geoshpere
#------------------------------------

#-----------START-------------

#Set working directories




#1.Function for computing distance matrix.Returns a distance matrix of all points between OMI and the user defined source.
#parameter: source2 which is the source of your data
#Note- Currently I have set the default to EIA, but can add flexibility in the future to read different sources
Compute_Distance_Matrix<- function(source="EIA"){
  #Required libraries
  library(geosphere)
  library(dplyr)

  DistanceFile<- read.csv(paste('OMI_Data_Mapping/Data/DistanceMatrices/DistanceFile',source,".csv",sep = ""),stringsAsFactors = FALSE)
  print('Please make sure that the file DistanceFile.csv is updated with the location data')
  source1<- subset(DistanceFile,Source=="OMI")
  source2<- subset(DistanceFile,Source==source)
  rownames<- source2$index
  colnames<- source1$index


  data<- distm(source2[,3:4],source1[,3:4],fun=distVincentyEllipsoid)/1000
  m<- as.matrix(data)

  rownames(m) <- rownames
  colnames(m) <- colnames

  return(m)
}


#2.Function for reading in distance matrix
#Note-This will look for the matrix. If it is in place, it will just read that file in. If not, run the Compute_Distance_Matrix function and calculate.
Read_Distance_Matrix<- function(source="EIA"){if (!file.exists(paste('OMI_Data_Mapping/Data/DistanceMatrices/DistanceMatrixFinal',source,'.csv',sep=""))){
  DistanceData<-Compute_Distance_Matrix(source)
  #colnames(DistanceData)[1]<-"PlantName"
  write.csv(DistanceData,file.path('OMI_Data_Mapping/Data/DistanceMatrices',paste('DistanceMatrixFinal',source,'.csv',sep="")))

}
  Distance_File<-read.csv(paste('OMI_Data_Mapping/Data/DistanceMatrices/','DistanceMatrixFinal',source,'.csv',sep=""),stringsAsFactors = FALSE)
  return(Distance_File)
}


#3. Final function for calculating OMI dataset. parameters are 'year'- The relevant year of comparison, 'Range'- distance range for aggregating data within a certain distance of each other (default is set to 36 kms),'minvalue'- The minimum value to ignore in the dataset.
#parameters: year=year for getting OMI data, range=distance range, min value is the minimum value to delete
GET_OMI_Data_EIA<-function(year=2017,range=36,minvalue=0,doubleCounting=TRUE){
  #Required libraries
  library(dplyr)
  library(magrittr)

  #1. Read Data

  #Read distance matrix

  Distance_File<- Read_Distance_Matrix("EIA")

  #1.a. Read OMI Data
  OMI_Data<- read.csv('OMI_Data_Mapping/Data/OMI/OMIData.csv',stringsAsFactors = FALSE)
  OMI_Data$ValueFromEIA<-NA
  OMI_Data<- filter(OMI_Data,SOURCETY != 'Volcano')
  #Might want to make the below line a parameter  in the future so the code can be used for other countries
  OMI_Data<- filter(OMI_Data,COUNTRY=='USA')
  OMI_Data<- dplyr::select(OMI_Data,c('NAME','COUNTRY',"ValueFromEIA",paste("y",year,sep = "")))
  colnames(OMI_Data)<- c("PlantName","Country","ValuefromEIA","Value")
  OMI_Data$Year=year
  OMI_Data %>% filter(Value>0)->OMI_Data



  #1.b.Read EIA data
  EIA_Data<- read.csv(paste('OMI_Data_Mapping/Data/EIA/emissions',year,'.csv',sep = ""),stringsAsFactors = FALSE)
  EIA_Data$Selected.SO2.Emissions..Metric.Tonnes.<- as.numeric(as.character(EIA_Data$Selected.SO2.Emissions..Metric.Tonnes.))
  EIA_Data_Final<- aggregate(EIA_Data$Selected.SO2.Emissions..Metric.Tonnes.,by=list(EIA_Data$Plant.Name),FUN=sum )
  names(EIA_Data_Final)<- c("PlantName","Value")
  EIA_Data_Final<- filter(EIA_Data_Final, Value> (minvalue/0.001))
  EIA_Data_Final$Year<- year


  #1.c.Rename first column in distance file (Need this during the merge)
  colnames(Distance_File)[1]<-"PlantName"

  #2.a. Start loop for merging OMI data with other source
  for (row in 1:nrow(OMI_Data)){




    Plant_name_OMI<- toString(OMI_Data[row,1])
    Plant_name_OMI<-gsub(" ",".",Plant_name_OMI)
    select_data<-dplyr::select(Distance_File,"PlantName",Plant_name_OMI)
    mergeddata<- left_join(EIA_Data_Final,select_data,by="PlantName")
    colnames(mergeddata)<- c("PlantName","Value","Year","Distance")
    mergeddata<- filter(mergeddata,Distance <range)

    #Add code for removing duplicates in consolidation
    EIA_Data_Final<-filter(EIA_Data_Final,!EIA_Data_Final$PlantName %in% c(unique(mergeddata$PlantName)))

    val<-(sum(as.numeric(mergeddata$Value),na.rm = TRUE))
    OMI_Data[row,3]<- val
  }

  #2.b.-Finally compute error term here

  #kbn-2019/12/18-START-Add code formerging in zero detections from EIA data into OMI dataset
  EIA_Data_Final %>% rename(ValuefromEIA=Value) %>% mutate(Value=0,Country="USA")->EIA_Data_Final
  OMI_Data<-rbind(OMI_Data,EIA_Data_Final)
  #kbn-2019/12/18-END

  OMI_Data$ValueFromEIAinKT<- OMI_Data$ValuefromEIA*0.001
  OMI_Data$Error<- OMI_Data$Value-(OMI_Data$ValueFromEIAinKT)
  OMI_Data$Range<- paste("Within a range of ",range," kms",sep="")

  OMI_Data<- filter(OMI_Data,Value >= 0)

  return(OMI_Data)

}

GET_OMI_Data_NEI<-function(year=2014,range=36,minvalue=0){
  #Required libraries
  library(dplyr)
  library(magrittr)

  #1. Read Data

  #Read distance matrix

  Distance_File<- Read_Distance_Matrix("NEI")

  #1.a. Read OMI Data
  OMI_Data<- read.csv('OMI_Data_Mapping/Data/OMI/OMIData.csv',stringsAsFactors = FALSE)
  OMI_Data$ValueFromNEI<-NA
  OMI_Data<- filter(OMI_Data,SOURCETY != 'Volcano')
  #Might want to make the below line a parameter  in the future so the code can be used for other countries
  OMI_Data<- filter(OMI_Data,COUNTRY=='USA')
  OMI_Data<- dplyr::select(OMI_Data,c('NAME','COUNTRY',"ValueFromNEI",paste("y",year,sep = "")))
  colnames(OMI_Data)<- c("PlantName","Country","ValuefromNEI","Value")
  OMI_Data$Year=year
  OMI_Data %>% filter(Value>0)->OMI_Data


  #1.b.Read NEI data
  NEI_Data<- read.csv(paste('OMI_Data_Mapping/Data/NEI/emissions',year,'.csv',sep = ""),stringsAsFactors = FALSE)
  NEI_Data$Selected.SO2.Emissions..Metric.Tonnes.<- as.numeric(as.character(NEI_Data$Selected.SO2.Emissions..Metric.Tonnes.))
  NEI_Data_Final<- aggregate(NEI_Data$Selected.SO2.Emissions..Metric.Tonnes.,by=list(NEI_Data$PlantName),FUN=sum )
  names(NEI_Data_Final)<- c("PlantName","Value")
  NEI_Data_Final<- filter(NEI_Data_Final, Value> (minvalue/0.001))
  NEI_Data_Final$Year<- year


  #1.c.Rename first column in distance file (Need this during the merge)
  colnames(Distance_File)[1]<-"PlantName"

  #2.a. Start loop for merging OMI data with other source
  for (row in 1:nrow(OMI_Data)){

    Plant_name_OMI<- toString(OMI_Data[row,1])
    Plant_name_OMI<-gsub(" ",".",Plant_name_OMI)
    select_data<-dplyr::select(Distance_File,"PlantName",Plant_name_OMI)
    mergeddata<- left_join(NEI_Data_Final,select_data,by="PlantName")
    colnames(mergeddata)<- c("PlantName","Value","Year","Distance")
    mergeddata<- filter(mergeddata,Distance <range)
    val<-(sum(as.numeric(mergeddata$Value),na.rm = TRUE))
    OMI_Data[row,3]<- val
    #Add code for removing duplicates in consolidation
    NEI_Data_Final<-filter(NEI_Data_Final,!NEI_Data_Final$PlantName %in% c(unique(mergeddata$PlantName)))

  }

  #2.b.-Finally compute error term here
  #kbn-2019/12/18-START-Add code formerging in zero detections from EIA data into OMI dataset
  NEI_Data_Final %>% rename(ValuefromNEI=Value) %>% mutate(Value=0,Country="USA")->NEI_Data_Final

  OMI_Data<-rbind(OMI_Data,NEI_Data_Final)
  #kbn-2019/12/18-END



  OMI_Data$ValueFromNEIinKT<- OMI_Data$ValuefromNEI*0.001*0.907185
  OMI_Data$Error<- OMI_Data$Value-(OMI_Data$ValueFromNEIinKT)
  OMI_Data$Range<- paste("Within a range of ",range," kms",sep="")


  OMI_Data<- filter(OMI_Data,Value >= 0)
  return(OMI_Data)

}


GET_OMI_Data_EGRIDS<-function(year=2014,range=36,minvalue=0){
  #Required libraries
  library(dplyr)
  library(magrittr)

  #1. Read Data

  #Read distance matrix

  Distance_File<- Read_Distance_Matrix("EGRIDS")

  #1.a. Read OMI Data
  OMI_Data<- read.csv('OMI_Data_Mapping/Data/OMI/OMIData.csv',stringsAsFactors = FALSE)
  OMI_Data$ValueFromEGRIDS<-NA
  OMI_Data<- filter(OMI_Data,SOURCETY != 'Volcano')
  #Might want to make the below line a parameter  in the future so the code can be used for other countries
  OMI_Data<- filter(OMI_Data,COUNTRY=='USA')
  OMI_Data<- dplyr::select(OMI_Data,c('NAME','COUNTRY',"ValueFromEGRIDS",paste("y",year,sep = "")))
  colnames(OMI_Data)<- c("PlantName","Country","ValuefromEGRIDS","Value")
  OMI_Data$Year=year
  OMI_Data %>% filter(Value>0)->OMI_Data


  #1.b.Read EGRIDS data
  NEI_Data<- read.csv(paste0('OMI_Data_Mapping/Data/EGRIDS/emissions',year,'.csv'),stringsAsFactors = FALSE) %>% distinct()
  NEI_Data$SO2emissions<- as.numeric((NEI_Data$SO2emissions))
  NEI_Data_Final<- aggregate(NEI_Data$SO2emissions,by=list(NEI_Data$PlantName),FUN=sum )
  #write.csv(NEI_Data_Final,"NEI_DATA_TEST.csv")
  names(NEI_Data_Final)<- c("PlantName","Value")
  NEI_Data_Final<- filter(NEI_Data_Final, Value> (minvalue/0.001))
  NEI_Data_Final$Year<- year


  #1.c.Rename first column in distance file (Need this during the merge)
  colnames(Distance_File)[1]<-"PlantName"

  #2.a. Start loop for merging OMI data with other source
  for (row in 1:nrow(OMI_Data)){

    Plant_name_OMI<- toString(OMI_Data[row,1])
    Plant_name_OMI<-gsub(" ",".",Plant_name_OMI)
    select_data<-dplyr::select(Distance_File,"PlantName",Plant_name_OMI)
    mergeddata<- left_join(NEI_Data_Final,select_data,by="PlantName")
    colnames(mergeddata)<- c("PlantName","Value","Year","Distance")
    mergeddata<- filter(mergeddata,Distance <range) %>% select(-Distance) %>% distinct()

    # if (Plant_name_OMI =="Homer.City"){
    #
    #   write.csv(mergeddata, "HomerCity.csv")
    # }

    val<-(sum(as.numeric(mergeddata$Value),na.rm = TRUE))
    OMI_Data[row,3]<- val
    #Add code for removing duplicates in consolidation
    NEI_Data_Final<-filter(NEI_Data_Final,!NEI_Data_Final$PlantName %in% c(unique(mergeddata$PlantName)))

  }


  #2.b.-Finally compute error term here
  #kbn-2019/12/18-START-Add code formerging in zero detections from EIA data into OMI dataset
  NEI_Data_Final %>% rename(ValuefromEGRIDS=Value) %>% mutate(Value=0,Country="USA")->NEI_Data_Final


  OMI_Data<-rbind(OMI_Data,NEI_Data_Final)
  #kbn-2019/12/18-END



  OMI_Data$ValueFromEGRIDSinKT<- OMI_Data$ValuefromEGRIDS*0.001
  OMI_Data$Error<- OMI_Data$Value-(OMI_Data$ValueFromEGRIDSinKT)
  OMI_Data$Range<- paste("Within a range of ",range," kms",sep="")


  OMI_Data<- filter(OMI_Data,Value >= 0)
  return(OMI_Data)

}



#Final Chunk- Get consolidated data with the function below
#parameters: startyear & endyear- These are the first and last years for calculation, startrange & endrange- These are the minimum
#and maximum distance ranges, rangesequence- The sequence in which the range is expected to increase
#Note- specify a start year and end year

Get_Consolidated_OMI_Data<-function(source="EIA",years=c(2013,2017),startrange=10,endrange=50,rangesequence=10,minvalue=0){
  Distance_File<-Read_Distance_Matrix(source)
  dataframe<- data.frame(matrix(ncol=8))
  funcname<- paste("GET_OMI_Data_",source,sep="")
  colnames(dataframe)<- c("PlantName","Country",paste("Valuefrom",source,sep=""),"Value","Year",paste("Valuefrom",source,"inKT",sep=""),"Error","Range")

  for (i in years){
      for(x in seq(startrange,endrange,rangesequence)){
      y<- get(funcname)(year=i,range=x,minvalue)
      colnames(y)<-c("PlantName","Country",paste("Valuefrom",source,sep=""),"Value","Year",paste("Valuefrom",source,"inKT",sep=""),"Error","Range")
      dataframe<-rbind(dataframe,y)
    }
  }

  dataframe<-dataframe[-1,]

  #Compute error statistics
  dataframe<-dataframe%>%
    #1.Absolute total error
    mutate(Total_Error=sum(abs(Error)))%>%
    #2.Absolute total by year
    group_by(Year)%>%
    mutate(Total_Error_By_Year=sum(abs(Error)))%>%
    mutate(Total_Error_By_Year_N=n())%>%
    ungroup()%>%
    #3.Absolute total by year,range
    group_by(Year,Range)%>%
    mutate(Total_Error_By_Year_By_Range=sum(abs(Error)))%>%
    mutate(Total_Error_By_Year_By_Range_N=n())%>%
    ungroup()%>%
    #4.Absolute total by year,plant,range
    group_by(PlantName,Year,Range)%>%
    mutate(Total_Error_By_PlantYearRange=sum(abs(Error)))%>%
    mutate(Total_Error_By_PlantYearRange_N=n())%>%
    ungroup()%>%
    #5.Absolute total by year,plant
    group_by(PlantName,Year)%>%
    mutate(Total_Error_By_PlantYear=sum(abs(Error)))%>%
    mutate(Total_Error_By_PlantYear_N=n())%>%
    ungroup()%>%
    #6.Absolute total by plant,range
    group_by(PlantName,Range)%>%
    mutate(Total_Error_By_PlantRange=sum(abs(Error)))%>%
    mutate(Total_Error_By_PlantRange_N=n())%>%
    ungroup()%>%
    #7. Total percent error
    mutate(Percent_Error_Total=(sum(abs(Error))/sum(Value))*100)%>%
    group_by(Year)%>%
    mutate(Percent_Error_ByYear=(sum(abs(Error))/sum(Value))*100)%>%
    ungroup()%>%
    #8. Total percent error by year, range
    group_by(Year,Range)%>%
    mutate(Percent_Error_ByYearRange=(sum(abs(Error))/sum(Value))*100)%>%
    ungroup()%>%
    #9. Total percent error by plant, year, range
    group_by(PlantName,Year,Range)%>%
    mutate(Percent_Error_ByPlantYearRange=(sum(abs(Error))/sum(Value))*100)%>%
    ungroup()%>%
    #10. Total percent error by plant, year
    group_by(PlantName,Year)%>%
    mutate(Percent_Error_ByPlantYear=(sum(abs(Error))/sum(Value))*100)%>%
    ungroup()%>%
    #11. Total percent error by plant,  range
    group_by(PlantName,Range)%>%
    mutate(Percent_Error_ByPlantRange=(sum(abs(Error))/sum(Value))*100)%>%
    ungroup() %>%
    mutate(Status=if_else(dataframe[,paste("Valuefrom",source,"inKT",sep="")]>0,"Detected","Undetected")) %>%
    mutate(Status=if_else(Value>0,Status,"Zero value from OMI"))




  return(dataframe)
}

#Test code to check whether data is produced correctly. Comment out if not testing


#-----------END-------------

