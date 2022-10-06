#EXTRACT DATA AND PROCESS SCRIPT
#set working directory. The working directory you select should represent an experiment that has been analyzed 
#by Fiji macros "Watershed". If running tutorial select "Example Data post watershed"
dir=choose.dir(default = "", caption = "Select folder")
setwd(dir)
#folders is a variable that contains the names of each mouse in experiment
folders=list.dirs(full.names=FALSE,recursive = FALSE)
y=1
#while loop to step through folders in experiment
while(y<=length(folders)){
setwd(paste(dir,"\\",folders[y],sep = ""))
#Experiment is generated so that file path can be modified
Experiment = getwd()
#Experiment1 is generated to save original file path
Experiment1 = getwd()
w=0
#This while loop is in place to perform the same script on both cellfill and cellannu data
while(w<2){
  if(w==1){
    Experiment=Experiment1
  }
z=0
#This while loop is in place to perform the same script on both experimental data and No Primary Ctl data
while(z<2){
  #Sets directory to No Primary Ctl data if it exsists
  if(z==1){
    if(file.exists(paste(Experiment,"\\No Primary Ctl", sep=""))){
    setwd(paste(Experiment,"\\No Primary Ctl\\", sep=""))
    Experiment = getwd()
    }else{
      break
    }
  }
  
  #if logic here sets file path as follows depending on where you are in loops
  if(z==1){
    #sets to No Primary Ctl folder
  setwd(paste(Experiment,"\\csv files\\", sep=""))
  }
  if(w==0&&z==0){
    #sets to cell fill folder
    setwd(paste(Experiment,"\\csv files\\cellfill", sep=""))
  }
  if(w==1&&z==0){
    #sets to cellannu folder
    setwd(paste(Experiment,"\\csv files\\cellannu", sep=""))
  }
  #Creates folder that analysis will be saved in
  dir.create("Output")
  #Images is a list of each .csv file for DRG sections analyzed in an individual mouse
  Images = list.files()
  #Excludes any directories
  Images = Images[!file.info(Images)$isdir]
  setwd(paste(Experiment,"\\rois\\", sep=""))
  #Imagesname is a list of each image name that will be used for __ 
  Imagesname = list.files()
  Imagesname = Imagesname[!file.info(Imagesname)$isdir]
  if(z==1){
    setwd(paste(Experiment,"\\csv files\\", sep=""))
  }
  if(w==0&&z==0){
    setwd(paste(Experiment,"\\csv files\\cellfill", sep=""))
  }
  if(w==1&&z==0){
    setwd(paste(Experiment,"\\csv files\\cellannu", sep=""))
  }
  totalfiles = length(Images)
  n=1
  m=2
  x=1
  Values= vector()
  Slice=vector()
  #Reads csv files for fist image to get the number of color channels in image ie nrow(Valuefile)
  Valuefile = read.csv(Images[1])
  #This loop concatenates all of the mean pixel values of one channel from each ROI and each image into one .csv file 
  #and creates a .csv file called Channel 1.csv, Channel 2.csv ect. Saved in Output folder. 
  while (x<=nrow(Valuefile)){
    n=1
    #Initialize vectors
    Image=vector()
    Values= vector()
    nameTemp = vector()
    Slice = vector()
    #This loop steps through each image
    while (n<=totalfiles){
      Valuefile = read.csv(Images[n])
      #Deletes channel info left in from Fiji macros
      Valuefile=Valuefile[,-1]
      j=1
      #This loop makes a vector Slice that is appended to final csv file so that you can reference which data
      #is from which image. It also makes a vector Image that is also appended to the final csv so that you know
      #how many total images were analyzed. Image vector is also useful for later dot plots.
      while (j<=length(Valuefile)){
        nameTemp=paste(Imagesname[n],j)
        Slice=append(Slice,nameTemp)
        Image=append(Image,n)
        j=j+1
      }
      
      
      #Concatenates mean pixel values of ROIs from all images of channel x to the vector "Values".
      Values=append(Values, Valuefile[x,])
      n=n+1
    }
    
    #Save results where results are all mean pixel values from each slice for one channel and their corresponding 
    #image name (Slice) and image number (Image)
    results = cbind(Image,Slice,Values)
    #If logic to set the appropriate directory
    if(z==1){
      setwd(paste(Experiment,"\\csv files\\Output\\", sep=""))
    }
    if(w==0&&z==0){
      setwd(paste(Experiment,"\\csv files\\cellfill\\Output\\", sep=""))
    }
    if(w==1&&z==0){
      setwd(paste(Experiment,"\\csv files\\cellannu\\Output\\", sep=""))
    }
    #Saves file
    write.csv(results,paste("Channel",x,".csv", sep=""))
    #Resets directory for next loop iteration
    if(z==1){
      setwd(paste(Experiment,"\\csv files\\", sep=""))
    }
    if(w==0&&z==0){
      setwd(paste(Experiment,"\\csv files\\cellfill\\", sep=""))
    }
    if(w==1&&z==0){
      setwd(paste(Experiment,"\\csv files\\cellannu\\", sep=""))
    }
    x=x+1
  }
  
  ##Combines all four channel csv files into one
  if(z==1){
    setwd(paste(Experiment,"\\csv files\\Output\\", sep=""))
  }
  if(w==0&z==0){
    setwd(paste(Experiment,"\\csv files\\cellfill\\Output", sep=""))
  }
  if(w==1&&z==0){
    setwd(paste(Experiment,"\\csv files\\cellannu\\Output", sep=""))
  }
  #Read all concatenated data for three channels
  Ch1 = read.csv("Channel1.csv")
  Ch2 = read.csv("Channel2.csv")
  Ch3 = read.csv("Channel3.csv")
  #if statement that allows code to process 3 or 4 color channel images. Will need to modify here if you want to 
  #process 1 or 2 channel images. *See comment bellow as well which will additionally need to be modified
  #for 1 or 2 channel images.
  if(nrow(Valuefile)==4){
  Ch4 = read.csv("Channel4.csv")
  Ch4=Ch4[,4]
  }
  #Removes redundant information
  Ch1=Ch1[,2:4]
  Ch2=Ch2[,4]
  Ch3=Ch3[,4]
  #*this part of the code will also need to be modified for 1 and 2 channel images.
  if(nrow(Valuefile)==4){
  Final = cbind(Ch1,Ch2,Ch3,Ch4)
  } else {
    Final = cbind(Ch1,Ch2,Ch3)
  }
  #Saves file AllCh.csv which is combined channels
  write.csv(Final,"AllCh.csv")
  z=z+1
}
w=w+1
}

###THIS SECTION OF CODE FINDS ROIS WHICH CONTAIN 2 OR MORE CELLS
##The ratio of pixel intensities (normalized to the mean of each channel) along a line path of each ROI of 
##channel 1 with channel 2 or channel 1 with channel 3 or channel 1 with channel 4 and so on is taken. 
##The ratio of each two channels is then fit as a mixture of two normal distributions. The mixing proportions (lambda)
##and the ratio of the two fit means (mu1/mu2) are compared to preset threshold values. If these proportions are
##outside of threshold values the ROI is considered to contain two cells and is removed in line __ of this script.
##Would love to find better method to do this.

setwd(Experiment1)
#Initialize variables. These variable were chosen to make selection of rois containing 2 or more cells 
#very stringent (has to obviously be 2 cells). Changing these values could reduce the number of rois containing 
#2 cells but also can start to get rid of data that is not 2 cells.
#bigdif sets the threshold for whether or not data in an ROI is even tested to have two ROIs
bigdif=0.6
#isbetween1 and 2 sets the threshold for what the mixing proportions should be between to be considered two cells
isbetween1=0.1
isbetween2=0.9
#meandiff sets the threshold for what the ratio of the two fitted means has to be below to be considered two cells
meandiff=0.6
library(mixtools)
library(dplyr)
setwd(paste(Experiment1,"\\csv files\\cellfill\\Output", sep=""))
#read csv file to extract image names when compiling final output
Getdanames = read.csv("AllCh.csv")
#Change working directory to data set containing pixel intensities along a line path of each ROI
setwd(paste(Experiment1,"\\Cell Profiles", sep=""))
Filenames = list.files()
finfinfin=vector()
justfin=matrix(ncol = 18)
z=1
#This while loop steps through line path pixel values for each image in the data set.
while(z<length(Filenames)){
  fin=vector()
  fin1=vector()
  #read files for one image
    df1=read.csv(Filenames[z])
    df1=df1[,-1]
    df2=read.csv(Filenames[z+1])
    df2=df2[,-1]
    df3=read.csv(Filenames[z+2])
    df3=df3[,-1]
    df4=read.csv(Filenames[z+3])
    df4=df4[,-1]
    #intialize vectors and variables
    x=2
    avg1=vector()
    avg2=vector()
    izgoo11=vector()
    izgoo21=vector()
    izgoo31=vector()
    izgoo12=vector()
    izgoo22=vector()
    izgoo32=vector()
    izgoo13=vector()
    izgoo23=vector()
    izgoo33=vector()
    izgoo14=vector()
    izgoo24=vector()
    izgoo34=vector()
    izgoo15=vector()
    izgoo25=vector()
    izgoo35=vector()
    izgoo16=vector()
    izgoo26=vector()
    izgoo36=vector()
    #This while loop steps through each ROI and tests if they contain two cells
    while(x<=length(df1)){
      #normalize each channel of a single ROI to its mean and removes NAs
      me1=df1[,x]
      me1 = me1[!is.na(me1)]
      me1=me1/mean(me1)
      me2=df2[,x]
      me2 = me2[!is.na(me2)]
      me2=me2/mean(me2)
      me3=df3[,x]
      me3 = me3[!is.na(me3)]
      me3=me3/mean(me3)
      me4=df4[,x]
      me4 = me4[!is.na(me4)]
      me4=me4/mean(me4)
      #take the ratio of channel 1 to channel 2 or channel 1 to channel 3 and so on
      meratio1=me1/me2
      meratio2=me1/me3
      meratio3=me1/me4
      meratio4=me2/me3
      meratio5=me2/me4
      meratio6=me3/me4
      #First if statement decides if the ROI should be tested for two cells (doing every ROI is 
      #very computationally expensive and this was an easy way to test only ROIs that likely have two cells)
      if(sd(meratio1[is.finite(meratio1)])>bigdif){
        #fit of two mixed normal distributions
        ismixed=try(normalmixEM(meratio1[is.finite(meratio1)],maxrestarts = 1000),silent = TRUE)
        if(typeof(ismixed)=="list"){
          #puts fitted means into variable mus
        mus=c(ismixed$mu[1],ismixed$mu[2])
        #takes ratio of fitted means
        aresim1=min(mus)/max(mus)
        #puts mixing proportion into a variable
        aresim2=ismixed$lambda[1]
        #if statement decided if ROI contains two cells ie aresim3=1 or not aresim3=0
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
        }
        #else statement if ROI is not fit. aresim1 is assigned to the sd value of that ROI and aresim2 is set
        #arbitrarily to 10 so that non-fit data are easy to find in the MultiCell csv file
        }else{
        aresim1=sd(meratio1[is.finite(meratio1)])
        aresim2=10
        aresim3=0
        }
      #save values of test to vectors
      izgoo11=append(izgoo11,aresim1)
      izgoo21=append(izgoo21,aresim2)
      izgoo31=append(izgoo31,aresim3)
      #the rest of the if statements repeat the above code in all other channel comparisons
      if(sd(meratio2[is.finite(meratio2)])>bigdif){
        ismixed=try(normalmixEM(meratio2[is.finite(meratio2)],maxrestarts = 100),silent = TRUE)
        if(typeof(ismixed)=="list"){
        mus=c(ismixed$mu[1],ismixed$mu[2])
        aresim1=min(mus)/max(mus)
        aresim2=ismixed$lambda[1]
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
      }
        }else{
        aresim1=sd(meratio2)
        aresim2=10
        aresim3=0
      }
      izgoo12=append(izgoo12,aresim1)
      izgoo22=append(izgoo22,aresim2)
      izgoo32=append(izgoo32,aresim3)
      if(sd(meratio3[is.finite(meratio3)])>bigdif){
        ismixed=try(normalmixEM(meratio3[is.finite(meratio3)],maxrestarts = 100),silent =TRUE )
        if(typeof(ismixed)=="list"){
        mus=c(ismixed$mu[1],ismixed$mu[2])
        aresim1=min(mus)/max(mus)
        aresim2=ismixed$lambda[1]
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
      }
        }else{
        aresim1=sd(meratio3)
        aresim2=10
        aresim3=0
      }
      izgoo13=append(izgoo13,aresim1)
      izgoo23=append(izgoo23,aresim2)
      izgoo33=append(izgoo33,aresim3)
      if(sd(meratio4[is.finite(meratio4)])>bigdif){
        ismixed=try(normalmixEM(meratio4[is.finite(meratio4)],maxrestarts = 100),silent = TRUE)
        if(typeof(ismixed)=="list"){
        mus=c(ismixed$mu[1],ismixed$mu[2])
        aresim1=min(mus)/max(mus)
        aresim2=ismixed$lambda[1]
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
      }
        }else{
        aresim1=sd(meratio4)
        aresim2=10
        aresim3=0
      }
      izgoo14=append(izgoo14,aresim1)
      izgoo24=append(izgoo24,aresim2)
      izgoo34=append(izgoo34,aresim3)
      if(sd(meratio5[is.finite(meratio5)])>bigdif){
      ismixed = try(normalmixEM(meratio5[is.finite(meratio5)],maxrestarts = 100),silent = TRUE)
      if(typeof(ismixed)=="list"){
      mus=c(ismixed$mu[1],ismixed$mu[2])
        aresim1=min(mus)/max(mus)
        aresim2=ismixed$lambda[1]
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
      }
      }else{
        aresim1=sd(meratio5)
        aresim2=10
        aresim3=0
      }
      izgoo15=append(izgoo15,aresim1)
      izgoo25=append(izgoo25,aresim2)
      izgoo35=append(izgoo35,aresim3)
      if(sd(meratio6[is.finite(meratio6)])>bigdif){
        ismixed=try(normalmixEM(meratio6[is.finite(meratio6)],maxrestarts = 100),silent = TRUE)
        if(typeof(ismixed)=="list"){
        mus=c(ismixed$mu[1],ismixed$mu[2])
        aresim1=min(mus)/max(mus)
        aresim2=ismixed$lambda[1]
        if(between(aresim2,isbetween1,isbetween2) && (aresim1<meandiff)){
          aresim3=1
        }else{
          aresim3=0
        }
      }
        }else{
        aresim1=sd(meratio6)
        aresim2=10
        aresim3=0
      }
      izgoo16=append(izgoo16,aresim1)
      izgoo26=append(izgoo26,aresim2)
      izgoo36=append(izgoo36,aresim3)
      x=x+2
    }
    #combine data from above to determine if ROIs contain two cells (all the aresim1 values) into a single vector
      fin=cbind(izgoo31,izgoo32,izgoo33,izgoo34,izgoo35,izgoo36)
      #combine data from above of all ratios of different ROIs with one another
      fin1=cbind(izgoo11,izgoo21,izgoo31,izgoo12,izgoo22,izgoo32,izgoo13,izgoo23,izgoo33,
                 izgoo14,izgoo24,izgoo34,izgoo15,izgoo25,izgoo35,izgoo16,izgoo26,izgoo36)
      #finfin is final vector to test if ROI contains two cells
      finfin=rowSums(fin)
justfin=rbind(justfin,fin1)
  finfinfin=append(finfinfin,finfin)
  #step to next image
  z=z+4
}
#combine and save data into .csv files
justfin=na.omit(justfin)
justfin=cbind(justfin,Getdanames$Slice)
finfinfin=cbind(finfinfin,Getdanames$Slice)
setwd(paste(Experiment1,"\\csv files\\cellfill\\Output", sep=""))
write.csv(finfinfin,"Multi Cell.csv")
write.csv(justfin,"Multi Cell All Data.csv")
setwd(paste(Experiment1,"\\csv files\\cellannu\\Output", sep=""))
write.csv(finfinfin,"Multi Cell.csv")
write.csv(justfin,"Multi Cell All Data.csv")

###BACKGROUND SUBTRACT SCRIPT
##Subtracts background ROIs using No Primary Ctl data (if present) and using data that determined which ROIs have
##two cells in them
#Sets working directory to No Primary Ctl if exists
if(file.exists(paste(Experiment1,"\\No Primary Ctl", sep=""))){
setwd(paste(Experiment1,"\\No Primary Ctl\\csv files\\Output", sep=""))
  #takes the mean and standard deviation of each channel in the No Primary Ctl channel. These represent the mean
  #background and sd of that background.
BgVal = read.csv("AllCh.csv")
Ch1Bgm=mean(BgVal$Values)
Ch1sd=  sd(BgVal$Values)
Ch2Bgm=mean(BgVal$Ch2)
Ch2sd=   sd(BgVal$Ch2)
Ch3Bgm=mean(BgVal$Ch3)
Ch3sd=   sd(BgVal$Ch3)
Ch4Bgm=mean(BgVal$Ch4)
Ch4sd=   sd(BgVal$Ch4)
Bgm=cbind(Ch1Bgm,Ch2Bgm,Ch3Bgm,Ch4Bgm)
Bgsd=cbind(Ch1sd,Ch2sd,Ch3sd,Ch4sd)
setwd(paste(Experiment1,"\\csv files\\cellannu\\Output", sep=""))
#reads data to be tested against background
mydata= read.csv(paste("AllCh.csv", sep=""))
h=1
percent=vector()
#This while loop loops through each channel and finds what percentage of the data is background
while(h<nrow(Valuefile)+1){
  #RAWR selects the correct channel in the AllCh.csv file
  RAWR=mydata[h+3]
  k=0
  if(h==1){
    #This while loop makes sure the fit is consistent. Sometimes the normalmixEM has variability if this is not done.
    while (k<4) {
      #Fits data as a mix of normal distributions constrained to one distribution being the background
      mixra=normalmixEM(RAWR$Values,mean.constr = c(Bgm[h],NA),sd.constr=c(Bgsd[h],NA),epsilon = 1e-8)
      k=length(mixra$all.loglik)
    }
  }
  if(h==2){
    while (k<4) {
      mixra=normalmixEM(RAWR$Ch2,mean.constr = c(Bgm[h],NA),sd.constr=c(Bgsd[h],NA),epsilon = 1e-8)
      k=length(mixra$all.loglik)
    }
  }
  if(h==3){
    while(k<4){
      mixra=normalmixEM(RAWR$Ch3,mean.constr = c(Bgm[h],NA),sd.constr=c(Bgsd[h],NA),epsilon = 1e-8)
      k=length(mixra$all.loglik)
      
    }
  }
  if(h==4){
    while(k<4){
      mixra=normalmixEM(RAWR$Ch4,mean.constr = c(Bgm[h],NA),sd.constr=c(Bgsd[h],NA),epsilon = 1e-8)
      k=length(mixra$all.loglik)
    }
  }
  h=h+1
  #sets the percent of background to the mixing proportion of the background fluorescence 
  percenttemp=min(mixra$lambda)
  percent=append(percent,percenttemp)
}
w=0
#This while loop performs the same analysis on cellannu and cellfill data
while(w<2){
  if(w==0){
  setwd(paste(Experiment1,"\\csv files\\cellannu\\Output", sep=""))
  }
  if(w==1){
    setwd(paste(Experiment1,"\\csv files\\cellfill\\Output", sep=""))
  }
  #reads in the data to be tested and the previously generated test of which ROIs contain two cells
  Val=read.csv("AllCh.csv")
  test=read.csv("Multi Cell.csv")
  Val1=Val
 
  g=1
  #This while loop checks each ROI to see if it contains two cells and then removes it based on the previous test.
  while(g<=nrow(Val1)){
    if(test$finfinfin[g]>0){
    Val[g,]=NA
    
    g=g+1}else{
      g=g+1
    }
  }
  Val=na.omit(Val)
  #Saves the ROIs that are just one cell as a .csv file
  write.csv(Val,paste("AllCh One Cell.csv"))
##Background subtract ROIs based on background determined from No Primary Ctls
  #howmuch determines how much of the background to removed which is 5% + the percent calculated from
  #No Primary Ctls. 5% is added because often the method determining background underestimates background and
  #watershed segmentation always selects regions that are not cells.
  howmuch=(0.05+mean(percent))*length(Val$X)
  if(w==0){
    #This set of code normalizes all channels to their mean and creates a vector bonj that will be used to
    #sort cells by their brightness (relative to all channels)
  Val1=Val
  Val1$Values=Val1$Values/mean(Val1$Values)
  Val1$Ch2=Val1$Ch2/mean(Val1$Ch2)
  Val1$Ch3=Val1$Ch3/mean(Val1$Ch3)
  if(nrow(Valuefile)==4){
  Val1$Ch4=Val1$Ch4/mean(Val1$Ch4)
  bonj=Val1$Values+Val1$Ch2+Val1$Ch3+Val1$Ch4
  }else{
    bonj=Val1$Values+Val1$Ch2+Val1$Ch3
  }
  }
  #Combines values from all channels with bonj and sorts by bonj
  Val=cbind(Val,bonj)
  Val=Val[order(bonj),]
  g=0
  #This while loop subtracts all ROIs below background
  while(g<howmuch){
    Val=Val[-1,]
    g=g+1
  }
  #Saves background subtracted data
  write.csv(Val,paste("New Background Sub.csv"))

### CREATES REFERENCE .CSV FILE TO SEE WHICH ROIS ARE SUBTRACTED IN FIJI  
  This=read.csv(paste("New Background Sub.csv"))
  That=read.csv("AllCh.csv")
  One=as.character(This$Slice)
  Two=as.character(That$Slice)
  Del=c(One,Two)
  Del1=sort(Del)
  
  i=1
  #This while loop finds which ROIs have been removed
  while(i < length(Del1)){
    if(Del1[i]==Del1[i+1]){
      Del1=Del1[!Del1%in%Del1[i]]
    }else{
      i=i+1
    }
  }
  #Save values for ROIs that have been subtracted
  write.csv(Del1,paste("Subtracted ROIs.csv"))
  
  
  x=1
  This=read.csv("New Background Sub.csv")
  That=read.csv("AllCh.csv")
  This=This[order(This[,2]),]
  Outher=vector()
  i=1
  z=0
  #This while loop creates a vector Outher that indicates which ROIs were removed by assigning them a value of -1
  #Outher is then used in a Fiji macro to remove ROIs so that the subtracted ROIs can be easily visualized.
  while(i<=nrow(That)){
    if(is.na(This[i-z,5])){
      tempvect=i
      Outher=append(Outher,tempvect)
    }else{
      if(This[i-z,5]==That[i,4]&&This[i-z,6]==That[i,5]){
        tempvect=-1
        Outher=append(Outher,tempvect)
      }else{
        tempvect=i
        Outher=append(Outher,tempvect)
        z=z+1
      }
    }
    i=i+1
    
  }
  Final=cbind(Outher,That)
  #Saves final result in ohgosh which will be read by Fiji macro
  write.csv(Final,"ohgosh.csv")
w=w+1
}
}
y=y+1
}
