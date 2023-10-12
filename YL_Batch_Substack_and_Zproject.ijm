//Ask user to choose the input and output directories
directory = getDirectory("Choose input directory");
fileList = getFileList(directory);

results=directory+"/Results/";						// make a new file path name for a results folder
	File.makeDirectory(results);					// make the new results folder
	temp=directory+"/Temp/";								// make a new file path name for a Temp folder
	File.makeDirectory(temp);						// make the new Temp folder

//Count the maximum number of positions and slices in dataset
run("Bio-Formats Macro Extensions");

newPosition = 0;
newSlice = 0;
maxPosition = 0;
maxSlice = 0;

for (i=0; i<fileList.length; i++) {
	file = directory + fileList[i];
	Ext.setId(file);
	Ext.getSeriesCount(newPosition);
	Ext.getSizeZ(newSlice);

	//Save the largest number of slices within the dataset
	if (newSlice>maxSlice) {
		maxSlice = newSlice;
	}



//Ask user how many positions there are in each file
nPositions = getNumber("How many positions are in this dataset?", maxPosition); 

//Ask user how many experiments they woud like merged 
nExperiment= getNumber("How many experiments do you want to analyse?", fileList.length); 

//Ask user how many slices need to be added to stack
Slices = getNumber("How many slices do you want in each stack?", maxSlice); 
//Activate batch mode for speed
setBatchMode(true);

//Normalize Autofluor and GFP channel, remove autofluor, save result

//Open all 10 positions from set of lif files, one set of identical opsitions at a time
for(a=1; a<nPositions+1; a++) {	
	//Open the same position series from each lif file as a hyperstack
	for (i=0; i<nExperiment; i++) {
		file = directory + fileList[i];
		run("Bio-Formats Importer", "open=file color_mode=Default view=Hyperstack stack_order=XYCZT series_"+d2s(a,0)); 
		
		//Get name of opened stack
		title = getTitle();
		getDimensions(width, height, channels, slices, frames);

		//Check if it is a two channel image, abort if not
		if (channels != 2) {
		  exit("2-channel image required");
		}
		
        run("Make Substack...", "  slices=7,8,9 all" );

		run("Z Project...", "projection=[Max Intensity] all");

		//Normalize stack intensity and convert to 8 bit
		run("Enhance Contrast...", "saturated=0.001 normalize process_all use");
		run("8-bit");
		
		saveAs("Tiff", results + "Position " + a + " Experiment " + i );
		close();
		
	}
}

setBatchMode(false);