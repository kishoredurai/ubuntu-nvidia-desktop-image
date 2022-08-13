FROM kishoredurai/core-nvidia-focal:1.01.1

USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
WORKDIR $HOME

######### START CUSTOMIZATION ########


#environment config
ENV INST_SCRIPTS $STARTUPDIR/install

RUN apt-get update && apt-get install -y \
        libasound2 \
        libegl1-mesa \
        libgl1-mesa-glx \
        libxcomposite1 \
        libxcursor1 \
        libxi6 \
        libxrandr2 \
        libxrandr2 \
        libxss1 \
        libxtst6 \
    && cd /tmp/ && wget https://repo.anaconda.com/archive/Anaconda3-2020.11-Linux-x86_64.sh \
    && bash Anaconda3-20*-Linux-x86_64.sh -b -p /opt/anaconda3 \
    && rm -r /tmp/Anaconda3-20*-Linux-x86_64.sh \
    && echo 'source /opt/anaconda3/bin/activate' >> /etc/bash.bashrc \
    # Update all the conad things
    && bash -c "source /opt/anaconda3/bin/activate \
        && conda update -n root conda  \
        && conda update --all \
        && conda clean --all" \
    && /opt/anaconda3/bin/conda config --set ssl_verify /etc/ssl/certs/ca-certificates.crt \
    && /opt/anaconda3/bin/conda install pip \
    && mkdir -p /home/user/.pip \
    && chown -R 1000:1000 /opt/anaconda3 /home/kasm-default-profile/.conda/ 


# RUN  apt install r-base -y \
#     && wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.1093-amd64.deb \
#     && apt install ./rstudio-server-1.3.1093-amd64.deb -y


#RStudio Server
RUN apt-get update && apt-get -y install \
        software-properties-common \
    && apt-get update && apt-get install -y \
        gdebi-core \
        r-base \
    && cd /tmp && wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.1093-amd64.deb \
    && gdebi --n rstudio-server-*-amd64.deb \
    && rm -f rstudio-server-*-amd64.deb 

#RStudio
RUN apt-get update && apt-get -y install \
        software-properties-common \
    && apt-get update && apt-get install -y \
        gdebi-core \
        r-base \
    && cd /tmp && wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.4.1106-amd64.deb \
    && gdebi --n rstudio-*-amd64.deb \
    && rm -f rstudio-*-amd64.deb \
    && cp /usr/share/applications/rstudio.desktop $HOME/Desktop/ \
    && chmod +x $HOME/Desktop/*.desktop

# Install Chrome
COPY resources/install_chrome.sh /tmp/
RUN bash /tmp/install_chrome.sh

# Install MS Edge
COPY resources/install_edge.sh /tmp/
RUN bash /tmp/install_edge.sh


### Install Visual Studio Code
COPY ./resources/vs_code $INST_SCRIPTS/vs_code/
RUN bash $INST_SCRIPTS/vs_code/install_vs_code.sh  && rm -rf $INST_SCRIPTS/vs_code/


# COPY resources/RStudio.desktop $HOME/Desktop/
COPY resources/spyder.desktop $HOME/Desktop/
COPY resources/jupyter.desktop $HOME/Desktop/

# Install example packages in the conda environment
USER 1000
RUN bash -c "source /opt/anaconda3/bin/activate \
    && conda activate \
    && pip install \
        folium \
        pgeocode \
    && conda install -c conda-forge \
        basemap \
        matplotlib" 
    
USER root

COPY resources/post_run_root.sh /dockerstartup/kasm_post_run_root.sh

######### END CUSTOMIZATIONS ########

RUN chown -R 1000:0 $HOME

ENV HOME /home/user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

CMD ["--tail-log"]
