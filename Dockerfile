From rocker/r-ver:3.4.4

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
    autoconf \
    gcc \
    git \
    make \
    ssh \
    wget \
    build-essential \
    libssl-dev \
    libcurl4-openssl-dev \
    libatlas-base-dev \
    libmariadbclient-dev \
    libffi-dev \
    libxml2-dev \
    libncurses5-dev \
    python3-pip \
    && apt-get autoremove -y \
    && apt-get clean -y

RUN R -e "install.packages('devtools', dependencies = TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages('matrixStats', dependencies = TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "install.packages(c('plyr', 'caret', 'scales', 'sqldf', 'reshape2'), repos='http://cran.rstudio.com/')" && \
    R -e "source('https://bioconductor.org/biocLite.R'); biocLite('Biostrings'); biocLite('rtracklayer'); biocLite('GenomeInfoDb'); biocLite('IRanges'); biocLite('BSgenome'); biocLite('GenomicAlignments')" && \
    R -e "library(devtools); source('https://bioconductor.org/biocLite.R'); install_github('yuchaojiang/CODEX/package')"

# Download and install CN_Learn from Github
WORKDIR /opt/tools
RUN git clone --recursive https://github.com/girirajanlab/CN_Learn.git

# Install the tools required to run individual CNV callers
WORKDIR /opt/tools/CN_Learn/software
RUN tar -zxvf gatk-3.5.tar.gz && \
    tar -zxvf xhmm.tar.gz && \
    tar -zxvf clamms.tar.gz && \
    wget http://psychgen.u.hpc.mssm.edu/plinkseq_downloads/plinkseq-x86_64-latest.zip && \
    unzip plinkseq-x86_64-latest.zip && \
    cd plinkseq-0.10 && \
    wget http://psychgen.u.hpc.mssm.edu/plinkseq_resources/hg19/seqdb.hg19.gz && \
    gunzip seqdb.hg19.gz

# Install python
WORKDIR /opt/tools/CN_Learn/software
RUN wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tgz && \
    tar xzf Python-3.7.3.tgz && \
    cd Python-3.7.3 && \
    ./configure && make && make install

# Install PIP
RUN pip3 install -U 'numpy==1.16.1' && \
    pip3 install -U 'Cython==0.27.3' && \
    pip3 install -U 'pandas==0.24.2' && \
    pip3 install -U 'scipy==1.2.1' && \
    pip3 install -U 'scikit-learn==0.20.3' && \
    pip3 install -U 'pydot==1.4.1'

# Install htslib
WORKDIR /opt/tools/CN_Learn/software
RUN wget -c https://github.com/samtools/htslib/archive/1.3.2.tar.gz && \
    tar -zxvf 1.3.2.tar.gz && \
    mv htslib-1.3.2 htslib && \
    cd htslib && \
    autoreconf && \
    ./configure && make && make install

# Install samtools
WORKDIR /opt/tools/CN_Learn/software
RUN wget -c https://github.com/samtools/samtools/archive/1.3.1.tar.gz && \
    tar -zxvf 1.3.1.tar.gz && \
    cd samtools-1.3.1 && \
    make && make install

# Install bedtools
WORKDIR /opt/tools/CN_Learn/software
RUN apt-get install -y python-pip && \
    wget https://github.com/arq5x/bedtools2/releases/download/v2.27.1/bedtools-2.27.1.tar.gz && \
    tar -zxvf bedtools-2.27.1.tar.gz && \
    cd bedtools2 && \
    make

WORKDIR /opt/tools/CN_Learn/software
RUN rm gatk-3.5.tar.gz  && rm xhmm.tar.gz  && rm clamms.tar.gz && \
    rm Python-3.7.3.tgz && rm 1.3.2.tar.gz && rm 1.3.1.tar.gz  && \
    rm bedtools-2.27.1.tar.gz && rm plinkseq-x86_64-latest.zip

WORKDIR /opt/tools/CN_Learn

CMD ["/bin/bash"]
