Dear CRAN team,

This is an update of the {hwsdr} package (version 1.2). This package provides easy downloads of 'HWSD' soil data directly to your R workspace.

This update addresses two issues in spatial subsetting. First, the geographic extent order of coordinate bounding boxes was wrongly processed, leading to out of scope subsets. This issue is now corrected. In addition, index values while merging data using terra::subst() are not removed by default. This is the case now, setting unmatched indices to NA in the raster output maps.

Kind regards,
Koen Hufkens

----

I have read and agree to the the CRAN policies at:
http://cran.r-project.org/web/packages/policies.html

## test environments, local, CI and r-hub

- Ubuntu 22.04 install on R 4.5.0
- Ubuntu 22.04 on github actions (devel / release)
- github actions on Windows / MacOS (release)
- codecov.io code coverage at ~83%

## local R CMD check results

0 errors | 0 warnings | 0 notes