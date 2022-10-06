dir1 = getDirectory("Choose a Directory");
isbatch=1
setBatchMode("hide");
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
list = getFileList(dir+"\\data\\");
list1 = getFileList(dir+"\\rois\\");
splitDir= dir + "\\rois annu\\";
splitDir1 = dir + "\\rois in\\";
File.makeDirectory(splitDir);
File.makeDirectory(splitDir1);
	//Smalls size set to 3 um for DRG images at 2.8906 pix/um scale
      Smalls = 8.6718;
      //Dialog.create("Adjust size of your ROIs");
      //Dialog.addNumber("Select ROI width:", Smalls);
      //Dialog.show();
      //Smalls = Dialog.getNumber();
		run("Set Measurements...", "mean");
			for (z=0; z<list.length; z++) {
				roiManager("reset");
  				open(dir+"\\data\\"+list[z]);
  				imageName=getTitle;
  				open(dir+"\\rois\\"+list1[z]);
				//Make ROIs
      n = roiManager("count");
      	      if (n==0)
          exit("The ROI Manager is empty");
      for (i=0; i<n; i++) {
          roiManager("select", i);
          run("Enlarge...", "pixel enlarge="+Smalls*-1/2);
          run("Interpolate");
          roiManager("update");
      }
      run("Line Width...", "line="+Smalls);
      n = roiManager("count");
      if (n==0)
          exit("The ROI Manager is empty");
      for (i=0; i<n; i++) {
          roiManager("select", i);
                 run("Area to Line");
          roiManager("update");
      }
      n = roiManager("count");
      if (n==0)
          exit("The ROI Manager is empty");
      for (i=0; i<n; i++) {
          roiManager("select", i);
                 run("Line to Area");
          roiManager("update");
      }
      roiManager("Save", splitDir+imageName+"RoiSet.zip");
      close("*");
      roiManager("reset");
open(dir+"\\data\\"+list[z]);
open(dir+"\\rois\\"+list1[z]);
	      if (n==0)
          exit("The ROI Manager is empty");
      for (i=0; i<n; i++) {
          roiManager("select", i);
          run("Enlarge...", "pixel enlarge="+Smalls*-1/2);
          run("Interpolate");
          roiManager("update");
      }
      	 roiManager("Save", splitDir1+imageName+"RoiSet.zip");
      	 close("*");
      	 roiManager("reset");
			}
}
			
			




