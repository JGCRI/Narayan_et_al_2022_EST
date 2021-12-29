_your zenodo badge here_

# Narayan_etal_2022_ERL

**Evaluation of uncertainties in the anthropogenic SO2 emissions in the USA from NASA's OMI point source catalog**

Kanishka Narayan<sup>1\*</sup>,Steven J Smith <sup>1</sup>,
,Vitali E. Fioletov <sup>2</sup> & Chris A. McLinden <sup>2</sup>

<sup>1 </sup> Joint Global Change Research Institute, Pacific Northwest National Lab, Washington DC, USA 

<sup>2 </sup> Air Quality Research Division, Environment and Climate Change Canada, Toronto, Canada 


\* corresponding author:  kanishka.narayan@pnnl.gov

## Abstract
While SO2 emissions are an important driver of air pollution and have a significant impact on radiative forcing, not all large sources around the world are included in high quality emission inventories. Satellite remote sensing is a promising method of monitoring emissions from such sources that may be missing in inventories. We evaluated the uncertainties in anthropogenic sulfur dioxide (SO2) emissions from the OMI satellite measurements for the contiguous US using high quality emissions inventory data. Specifically, we evaluated uncertainties in OMI measurements from NASA's OMI point source catalog for different dimensions including uncertainties from emission sources that are undetected by the satellite, uncertainties introduced by small emitters, uncertainties from the composition of the emissions (powerplants vs non powerplants) etc. For sources that are detected by the satellite, we find that errors in aggregate (total of all detected sources) are relatively low. Moreover, errors are lowest when looking at comprehensive inventories i.e., inventories that include both powerplant and non-powerplant sources. Errors for individual sources can be substantial, however, with over or under-estimates ranging from -90% to +500% (roughly 10 - 90th percentile) in an asymmetric distribution with a long tail. We find that these errors are not necessarily random over time and that there can be consistent positive or negative biases for many sources over time.  We find, as expected, that emission sources not detected by the satellite are the largest aggregate source of difference between the satellite estimates and inventories, especially in more recent years where source emission sizes have been decreasing. This analysis of uncertainties provides information on the error structure of the OMI measurements, which is a useful guide when using this data for research and assessment.




## Data reference

### Input data
Available at zenodo here- 
Human, I.M. (2021). My input dataset name [Data set]. DataHub. https://doi.org/some-doi-number




## Reproduce my experiment
To reproduce the results and figures shown in Narayan et al.,

1. Install `R` here - https://www.r-project.org/
2. Install `R studio` from here - https://www.rstudio.com/
3. Download input data from- and place in folder `code_to_create_figures/OMI_Data_Mapping/Data/`
4. Run the script called `Replicating paper figures&results.rmd` from the folder `code_to_create_figures/` chunk by chunk to generate relevant figures.  
