# Pinned to linux/amd64 — rawrr's dotnet assembly is x64-only (no linux-arm64 binary).
# On Apple Silicon, Docker Desktop runs this via Rosetta 2.
FROM bioconductor/bioconductor_docker:3.21-r-4.5.2@sha256:359702d482e70e343d2a436731b7c6deffd1ec184a1f1700de5d64b0c97cacba

# System packages. apt-get upgrade is omitted to keep system library versions
# fixed to those in the base image, which matters for numerical reproducibility.
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl && \
    update-ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/*

# Set the Bioconductor mirror. CRAN and download settings are already
# configured in the base image to use RSPM binary packages; do not override them.
RUN printf '\noptions(BioC_mirror = "http://bioconductor.statistik.tu-dortmund.de/")\n' \
    >> /usr/local/lib/R/etc/Rprofile.site

# rawrr stores its dotnet assembly in the R user cache. Using a fixed path
# ensures the binary installed by root is accessible to the jupyter user.
ENV R_USER_CACHE_DIR=/opt/R-cache

COPY jupyter-r/install_jupyter.sh /tmp/install_jupyter.sh
COPY jupyter-r/requirements.txt* /tmp/
RUN bash /tmp/install_jupyter.sh

COPY jupyter-r/install_packages.R /tmp/install_packages.R
COPY jupyter-r/install_packages.sh /tmp/install_packages.sh
COPY jupyter-r/renv.lock* /tmp/
RUN bash /tmp/install_packages.sh

RUN R -e "IRkernel::installspec(user = FALSE)"

# Download the rawrr dotnet assembly and verify it was installed successfully.
RUN mkdir -p /opt/R-cache && \
    Rscript -e " \
    rawrr::installRawrrExe(); \
    cache_dir <- tools::R_user_dir('rawrr', 'cache'); \
    asm <- list.files(file.path(cache_dir, 'rawrrassembly'), \
                      recursive = TRUE, full.names = TRUE); \
    if (length(asm) == 0) \
      stop('rawrr assembly not installed. Check network access to fgcz-ms.uzh.ch.'); \
    message('rawrr OK: ', paste(asm, collapse = ', ')) \
    " && \
    chmod -R 755 /opt/R-cache

RUN useradd -m -u 1001 -s /bin/bash jupyter

RUN mkdir -p /home/jupyter/.jupyter /app/notebooks && \
    echo "c.ServerApp.root_dir = '/app/notebooks'" >> /home/jupyter/.jupyter/jupyter_server_config.py && \
    echo "c.IdentityProvider.token = ''" >> /home/jupyter/.jupyter/jupyter_server_config.py && \
    chown -R jupyter:jupyter /home/jupyter /app/notebooks

COPY --chown=jupyter:jupyter jupyter-r/entrypoint.sh /home/jupyter/entrypoint.sh
RUN chmod +x /home/jupyter/entrypoint.sh

USER jupyter
WORKDIR /home/jupyter

EXPOSE 8888

ENTRYPOINT ["bash", "/home/jupyter/entrypoint.sh"]
