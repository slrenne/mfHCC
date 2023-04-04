# Multifocal HCC

Given heach patient ($k$), each new clone ($j$), each non-clonal nodule ($i$), we will try to model, in the setting of Hepatocellular Carcinoma (HCC) the multifocality process. In our setting some of the nodules have been biopsied several times ($h$) and some nodule has not been biopsied but recorded ($z$). Therefore the total number of intrahepatic nodules in each patients ($N_{nod[k]}$) is the result of the sum of the total number nodules of each new clone $i^{\text{max}}_{j=1}$.


```math

\begin{align}
N_{nod[k]} &= \sum_{j=1}^{\text{max}(j_{[k]})}i_j + z\\
\text{max}(j_{[k]}) &= f(BLD_{[k]})\\
\text{max}(i_{[j,k]}) &= f(VETC_{P[j,k]}) + f(EMT_{P[j,k]}) \\
VETC_{P[j,k]} &= f(VETC_{[h,i,j,k]}) \\
EMT_{P[j,k]} &= f(EMT_{[h,i,j,k]})
\end{align}
```
