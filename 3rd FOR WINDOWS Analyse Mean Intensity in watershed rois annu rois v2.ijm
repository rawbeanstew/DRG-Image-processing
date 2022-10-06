dir1 = getDirectory("Choose a Directory");
isbatch=1
//setBatchMode("hide");
Smalls=8.6718;
run("Plots...", "width=600 height=340 font=14 draw_ticks list minimum=0 maximum=0 interpolate");
if (isbatch==1){
list0 = getFileList(dir1);
}else{
	list0 = "n";
}
for(j=0; j<list0.length; j++){
	if(isbatch==1){
	dir = dir1+list0[j];
	}else{
		dir=dir1;
	}
for(z=0; z<2; z++){
	if(z==1){
		if(File.exists(dir+"\\No Primary Ctl")==false){
			break
		}else {
		dir=dir+"No Primary Ctl";
		}
	}
list = getFileList(dir+"\\data\\");
list = Array.sort(list);
list1= getFileList(dir+"\\rois\\");
list1 = Array.sort(list1);
splitDir= dir + "\\csv files\\";
File.makeDirectory(splitDir);
if(z==0){
splitDir2=dir+"\\Cell Profiles\\";
File.makeDirectory(splitDir2);
list2= getFileList(dir+"\\rois annu\\");
list2 = Array.sort(list2);
splitDir= dir + "\\csv files\\cellfill\\";
File.makeDirectory(splitDir);
splitDir1= dir + "\\csv files\\cellannu\\";
File.makeDirectory(splitDir1);
}
run("Set Measurements...", "mean");
			for (i=0; i<list.length; i++) {
  				roiManager("reset");
  				open(dir+"\\data\\"+list[i]);
  				open(dir+"\\rois\\"+list1[i]);
				
			run("Clear Results");
			imageName=getTitle;
			roiManager("multi measure")
			saveAs("Results",splitDir+imageName+".csv");
         
			if(z==0){
			n = roiManager("count");
				      for (a=0; a<n; a++) {
          roiManager("select", a);
          run("Enlarge...", "pixel enlarge="+Smalls*-1/2);
          run("Interpolate");
          run("Area to Line");
          roiManager("update");
          roiManager("Remove Channel Info");
}
for (g = 0; g < 4; g++) {
run("Clear Results");
roiManager("Deselect");
roiManager("Multi Plot");
Table.rename("Plot Values", "Results");
saveAs("Results", splitDir2+imageName+g+".csv");
run("Clear Results");
selectWindow(imageName);
run("Next Slice [>]");
}
			roiManager("reset");
			run("Clear Results");
			open(dir+"\\rois annu\\"+list2[i]);
			roiManager("multi measure")
			saveAs("Results",splitDir1+imageName+".csv");
			}
			close("*");
			}
}
}


