FROM ubuntu:18.04


# Install required packages
RUN apt-get update
RUN apt-get install -y build-essential wget git autoconf

# Install dependencies for AUGUSTUS
RUN apt-get install -y libboost-iostreams-dev zlib1g-dev
RUN apt-get install -y libgsl-dev libboost-graph-dev libsuitesparse-dev liblpsolve55-dev libsqlite3-dev libmysql++-dev
RUN apt-get install -y libbamtools-dev
RUN apt-get install -y libboost-all-dev

# Install additional dependencies for htslib and samtools
RUN apt-get install -y libbz2-dev liblzma-dev
RUN apt-get install -y libncurses5-dev

# Install additional dependencies for bam2wig
RUN apt-get install -y libssl-dev libcurl3-dev

# Build bam2wig dependencies (htslib, bfctools, samtools)
RUN git clone https://github.com/samtools/htslib.git /root/htslib
WORKDIR "/root/htslib"
RUN autoheader
RUN autoconf
RUN ./configure
RUN make
RUN make install
RUN git clone https://github.com/samtools/bcftools.git /root/bcftools
WORKDIR "/root/bcftools"
RUN autoheader
RUN autoconf
RUN ./configure
RUN make
RUN make install
RUN git clone https://github.com/samtools/samtools.git /root/samtools
WORKDIR "/root/samtools"
RUN autoheader
RUN autoconf -Wno-syntax
RUN ./configure
RUN make
RUN make install
ENV TOOLDIR="/root"

# Clone AUGUSTUS repository
ADD / /root/augustus

# Build bam2wig
RUN mkdir -p /root/augustus/bin
WORKDIR "/root/augustus/auxprogs/bam2wig"
RUN make

# Build AUGUSTUS
WORKDIR "/root/augustus"
RUN make
RUN make install
ENV PATH="/root/augustus/bin:${PATH}"

# Test AUGUSTUS
RUN make test
