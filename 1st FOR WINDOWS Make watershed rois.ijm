//Increasing this value decreases segmentation decreasing this value increases segmentation
wsThreshold=26
//setting takeout to a value greater than 1 deletes that channel
takeout = 0
//This Macro creates the folders "watershed" "png" and "rois" in 
//the chosen directory. It then grabs images from the chosen directory 
//that are in a folder named "data"
//This macro then creates rois using watershed analysis of the images saving 
//those rois in the "rois" folder. The watershed dams are saved in
//the folder "watershed" and images used in watershed analysis are saved
//in the folder "png". The metadata.txt file contains the saturation and 
//wsThreshold values specified above. 
dir = getDirectory("Choose a Directory");
npctl=1
for(i=0; i<2; i++){
	if(i==1){
		if(File.exists(dir+"\\No Primary Ctl")==false){
			break
		}else {
		npctl=0;
		wsThreshold=20;
		dir=dir+"\\No Primary Ctl\\";
	}
	}
list = getFileList(dir+"\\data\\");
list = Array.sort(list);
list1= getFileList(dir+"\\cellsroi\\");
list1=Array.sort(list1);
splitDir1= dir + "\\png\\";
File.makeDirectory(splitDir1);
splitDir2= dir + "\\watershed\\";
File.makeDirectory(splitDir2);
splitDir3= dir + "\\rois\\";
File.makeDirectory(splitDir3);
for (z=0; z<list.length; z++) {
open(dir+"\\data\\"+list[z]);
imageName=getTitle;
selectWindow(imageName);
if(takeout>0 && npctl==1){
	for(g=1; g<takeout;) {
			      	run("Next Slice [>]");
			      	g=g+1;
			      }
	run("Delete Slice", "delete=channel");
}
run("Z Project...", "projection=[Average Intensity]");
//run("Enhance Contrast", "saturated="+saturation);
run("Enhance Local Contrast (CLAHE)", "blocksize=120 histogram=256 maximum=15 mask=*None* fast_(less_accurate)");
saveAs("PNG", splitDir1+imageName+".png");
//change Gaussian Blur and Median Blur for image to be segmented here
run("Gaussian Blur...", "sigma=2");
run("Median...", "radius=2");
run("Morphological Segmentation");
selectWindow("Morphological Segmentation");
selectWindow(imageName+".png");
selectWindow("Morphological Segmentation");
call("inra.ijpb.plugins.MorphologicalSegmentation.setInputImageType", "object");
//If you want to change the Gradient Radius do so here
call("inra.ijpb.plugins.MorphologicalSegmentation.setGradientRadius", "3");
call("inra.ijpb.plugins.MorphologicalSegmentation.setGradientType", "Morphological");
call("inra.ijpb.plugins.MorphologicalSegmentation.segment", "tolerance="+wsThreshold, "calculateDams=true", "connectivity=8");
call("inra.ijpb.plugins.MorphologicalSegmentation.setDisplayFormat", "Watershed lines");
wait(7000);
call("inra.ijpb.plugins.MorphologicalSegmentation.createResultImage");
saveAs("PNG", splitDir2+imageName+"-watershed-lines.png");
selectWindow(imageName+"-watershed-lines.png");
setAutoThreshold("Default dark");
if(npctl == 0){
run("Analyze Particles...", "size=0-10000 circularity=0-1.00 clear add");
}else{
	if(File.exists(dir+"\\cellsroi\\")==true){
	open(dir+"\\cellsroi\\"+list1[z]);
	}
//Set the size of ROIs analyzed in pixels and the circularity of the ROIs (1=perfect circle)
run("Analyze Particles...", "size=0-Inf circularity=0.4-1.00 clear add");
}
roiManager("Deselect");
roiManager("Save", splitDir3+imageName+" RoiSet.zip");
roiManager("reset");
close("*");
}
print("\\Clear"); //empties the Log
print("Watershed Threshold="+wsThreshold);
selectWindow("Log");  //select Log-window
saveAs("Text", dir+"Metadata");
}
