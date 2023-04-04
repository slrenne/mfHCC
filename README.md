# Multifocal HCC

Given heach patient ($k$), each new clone ($j$), each non-clonal nodule ($i$), we will try to model, in the setting of Hepatocellular Carcinoma (HCC) the multifocality process. In our setting some of the nodules have been biopsied several times ($h$) and some nodule has not been biopsied but recorded ($z$). Therefore the total number of intrahepatic nodules in each patients ($N_{nod[k]}$) is the result of the sum of the maximum number nodules of each new clone ($i^{\text{max}}_j$) and the non-biopsied nodules ($z$): 

```math
N_{nod[k]} = i^{\text{max}}_{j=1} + \cdots + i^{\text{max}}_{j=j^{\text{max}}} + z
```
Therefore we can simplify with:

```math

\begin{align}
N_{nod[k]} &= \sum_{j=1}^{\text{max}(j)}i_j + z\\
\text{max}(j_{[k]}) &= f(BLD_{[k]}) + T_j\\ 
\text{max}(i_{[j,k]}) &= f(VETC_{P[j,k]}) + f(EMT_{P[j,k]}) + T_i \\
VETC_{P[j,k]} &= f(VETC_{[h,i,j,k]}) \\
EMT_{P[j,k]} &= f(EMT_{[h,i,j,k]}) \\
z &= f(EMT_{P[j,k]}) + f(VETC_{P[j,k]}) \\
T_j &= f(age) \\ 
T_i &= f(age)
\end{align}
```
