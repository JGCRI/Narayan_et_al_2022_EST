_your zenodo badge here_

# Narayan_etal_2022_ERL

**Evaluation of uncertainties in the anthropogenic SO2 emissions in the USA from NASA's OMI point source catalog**

Kanishka Narayan<sup>1\*</sup>,Steven J Smith <sup>1</sup>,
,Vitali E. Fioletov <sup>2</sup> & Chris A. McLinden <sup>2</sup>

<sup>1 </sup> Joint Global Change Research Institute, Pacific Northwest National Lab, Washington DC, USA 

<sup>2 </sup> Air Quality Research Division, Environment and Climate Change Canada, Toronto, Canada 


\* corresponding author:  kanishka.narayan@pnnl.gov

## Abstract
While SO2 emissions are an important driver of air pollution and have a significant impact on radiative forcing, not all large sources around the world are included in emission inventories. Satellite remote sensing is a promising method of monitoring emissions that may be missing in inventories. We evaluated uncertainties in anthropogenic sulfur dioxide (SO2) emission estimates from NASA’s OMI point source catalog for the contiguous US. We compared emissions from the catalog with high quality emissions inventory data over different dimensions including, size of individual sources, aggregate vs individual source errors, and potential bias in in individual source estimates over time. For sources that are included in the catalog, we find that errors in aggregate (total of all included sources) are relatively low. Errors are lowest when comparing to comprehensive inventories i.e., inventories that include both powerplant and non-powerplant sources. Errors for individual sources in any given year can be substantial, however, with over or under-estimates in terms of total error ranging from -80 kt to 110 kt (roughly 10 - 90th percentile). We find that these errors are not necessarily random over time and that there can be consistently positive or negative biases for individual sources.  We find, as expected, that emission sources not included in the catalog are the largest aggregate source of difference between the satellite estimates and inventories, especially in more recent years where source emission magnitudes have been decreasing. This analysis of uncertainties provides information on the error structure of the OMI measurements, which is a useful guide when using this data for research and assessment.


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
