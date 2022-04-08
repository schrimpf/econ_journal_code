# econ\_journal\_code

Find articles in economics journals that include Julia code.

## Econometrica

Scraped by ecta.jl, which downloads the last 15mb of each article's
supplemental materials zip file. It then checks whether the zip file
contains any files with .jl extensions.

Recent papers with Julia code:
- [Morelli, Ottonello, and Perez (2022) "Global Banks and Systemic Debt Crises"](https://doi.org/10.3982/ECTA17433)
- [Bhandari, Evans, Golosov, and Sargent (2021) "Inequality, Business Cycles, and Monetary-Fiscal Policy"](https://doi.org/10.3982/ECTA16414)
- [Amador and Phelen (2021) "Reputation and Sovereign Default"](https://doi.org/10.3982/ECTA16685)
- [Currie and MacLeod (2020) "Understanding Doctor Decision Making: The Case of Depression Treatment"](https://doi.org/10.3982/ECTA16591)
- [Taber and Vejlin (2020) "Estimation of a Roy/Search/Compensating Differential Model of the Labor Market"](https://doi.org/10.3982/ECTA14441)

## Quantitative Economics

Scraped by qe.jl, which downloads each article's supplemental
materials zip file (the qe webserver ignores range requests, so we
cannot just download the of the zip files, we did not download files
larger than 1.5GB).. It then checks whether the zip file contains any
files with .jl extensions.

Recent papers with Julia code:
- [Baye and Luetticke (2020) "Solving discrete time heterogeneous agent models with aggregate risk and many idiosyncratic states by perturbation"](https://qeconomics.org/ojs/index.php/qe/article/view/1378)

## American Economic Review
AER has shifted from supplements in zip files to more varied formats (e.g. hosted on openICPSR, Harvard dataverse or other data archiving site). We simply searched openicpsr.org and for .jl files for this, so we are missing papers that host their code elsewhere.

Recent papers with Julia code:
- Perla, Jesse, Tonetti, Christopher, and Waugh, Michael E."Equilibrium Technology Diffusion, Trade, and Growth"  2020. https://doi.org/10.3886/E119393V1
-  Benhabib, Jess, and Szoke, Balint. "Optimal Positive Capital Taxes at Interior Steady States."  2020.  https://doi.org/10.3886/E116622V1


## ReStat

Found one paper using Julia with code on Harvard Dataverse:

- Hasenzagl, Thomas; Pellegrino, Filippo; Reichlin, Lucrezia; Ricco, Giovanni, "A Model of the Fed’s View on Inflation" 2020, https://doi.org/10.7910/DVN/XYZ1NA


## Other Journals

_Journal of Political Economy_ and _Review of Economic Studies_ put
the articles and supplements both behind paywalls. I have access, but
scraping is still made more complicated by the paywall.
