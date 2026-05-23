# Bootstrap renv
if (!requireNamespace("renv", quietly = TRUE))
  install.packages("renv", lib = .libPaths()[1])
library(renv, lib.loc = .libPaths()[1])

# Installs packages and stops if any failed
install_and_verify <- function(pkgs, installer) {
  installer(pkgs)
  installed_after <- rownames(installed.packages())
  failed <- pkgs[!pkgs %in% installed_after]
  if (length(failed) > 0)
    stop(sprintf("Failed to install: %s", paste(failed, collapse = ", ")))
  invisible(NULL)
}

pkgs_cran <- c(
  "repr", "IRdisplay", "IRkernel", "languageserver", "devtools", "tidyverse",
  "showtext", "ggplot2", "ggfortify", "ggforce", "ggtext", "ggrepel", "GGally",
  "ggVennDiagram", "eulerr", "patchwork", "cowplot", "metR", "scales",
  "doParallel", "combinat", "s2", "RColorBrewer"
)

to_install_cran <- pkgs_cran[!pkgs_cran %in% rownames(installed.packages())]
if (length(to_install_cran) > 0)
  install_and_verify(to_install_cran, install.packages)

# Bioconductor
pkgs_bioc <- c(
  "fgsea", "biomaRt", "enrichplot", "DOSE", "limma",
  "clusterProfiler", "AnnotationDbi", "org.Hs.eg.db",
  "rawrr", "ComplexHeatmap", "circlize", "MSstats", "MSstatsTMT"
)
to_install_bioc <- pkgs_bioc[!pkgs_bioc %in% rownames(installed.packages())]
if (length(to_install_bioc) > 0)
  install_and_verify(
    to_install_bioc,
    function(pkgs) {
      BiocManager::install(
        pkgs,
        ask = FALSE,
        site_repository = "http://bioconductor.statistik.tu-dortmund.de/"
      )
    }
  )

# Snapshot – lockfile lands in /app so it can be extracted via docker cp
dir.create("/app", showWarnings = FALSE)
renv::snapshot(
  lockfile  = "/app/renv.lock",
  prompt    = FALSE,
  type      = "all",
  library   = .libPaths()
)