
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6561309.svg)](https://doi.org/10.5281/zenodo.6561309)

# Narayan_etal_2023_ES&T

**Evaluation of uncertainties in the anthropogenic SO2 emissions in the USA from the OMI point source catalog**

*Accepted at Environmental Science and Technology

Kanishka Narayan<sup>1\*</sup>,Steven J Smith <sup>1</sup>,
,Vitali E. Fioletov <sup>2</sup> & Chris A. McLinden <sup>2</sup>

<sup>1 </sup> Joint Global Change Research Institute, Pacific Northwest National Lab, Washington DC, USA 

<sup>2 </sup> Air Quality Research Division, Environment and Climate Change Canada, Toronto, Canada 


\* corresponding author:  kanishka.narayan@pnnl.gov

## Abstract
Satellite remote sensing is a promising method of monitoring emissions that may be missing in inventories, but the accuracy of these estimates is often not clear. We demonstrate here a comprehensive evaluation of errors in anthropogenic sulfur dioxide (SO2) emission estimates from NASA’s OMI point source catalog for the contiguous US by comparing emissions from the catalog with high quality emissions inventory data over different dimensions including, size of individual sources, aggregate vs individual source errors, and potential bias in individual source estimates over time. For sources that are included in the catalog, we find that errors in aggregate (sum of error for all included sources) are relatively low. Errors for individual sources in any given year can be substantial, however, with over or under-estimates in terms of total error ranging from -80 kt to 110 kt (roughly 10 - 90th percentile). We find that these errors are not necessarily random over time and that there can be consistently positive or negative biases for individual sources. We did not find any overall statistical relationship between the degree of isolation of a source and bias, either at a 40km or 70km scales. For a sub-set of sources where inventory emissions over a radius of 70km around an OMI detection are larger than twice the emissions within 40km the OMI value is consistently overestimated. We find, as expected, that emission sources not included in the catalog are the largest aggregate source of difference between the satellite estimates and inventories, especially in more recent years where source emission magnitudes have been decreasing and note that trends in satellite detections do not necessarily track trends in total emissions. We find that the OMI based SO2 emissions are accurate in aggregate, when summed over a number of sources, but must be interpreted more cautiously at the individual source level. Similar analyses would be valuable for other satellite emission estimates, however in many cases the appropriate high-quality reference data may need to be generated.


## Data reference

### Input data
Available at zenodo here- 
Kanishka Narayan, & Steven Smith. (2021). Input data for Narayan et al 2022. (0.1.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.5809677

## Reproduce my experiment
To reproduce the results and figures shown in Narayan et al.,

1. Install `R` here - https://www.r-project.org/
2. Install `R studio` from here - https://www.rstudio.com/
3. Download input data from-https://doi.org/10.5281/zenodo.5809677 and place in folder `code_to_create_figures/OMI_Data_Mapping/Data/`
4. Run the script called `Replicating paper figures&results.rmd` from the folder `code_to_create_figures/` chunk by chunk to generate relevant figures.  
