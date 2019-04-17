FROM ubuntu:16.04

MAINTAINER K-Lab Authors <service@kesci.com>

USER root 

# Configure environment
ENV SHELL /bin/bash
ENV NB_USER kesci
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV KERAS_BACKEND tensorflow

# Install prerequisites
RUN apt-get update && apt-get -yqq dist-upgrade && \
    apt-get install -yqq --no-install-recommends \
    locales \
    bzip2 \
    ca-certificates \
    build-essential \
    sudo \
    wget \
    # Install all OS dependencies for fully functional notebook server
    git \
    # Install python2.7
    python-dev \
    && \
    # Setup locales
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    # Create kesci user with UID=1000 and in the 'users' group
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER

# Setup kesci home directory and install python2.7
RUN su -m -l $NB_USER -c '\
    mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/input && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc' && \
    # Make sure /usr/local/ directories belong to user, and install fonts.
    mkdir -p /home/$NB_USER/.cache && chown $NB_USER -R /home/$NB_USER/.cache && \
    # Allow kesci run sudo apt-get
    echo "kesci ALL=NOPASSWD: /usr/bin/apt-get" > /etc/sudoers.d/kesci && chmod 0400 /etc/sudoers.d/kesci && \
    cd /tmp && \
    wget https://bootstrap.pypa.io/get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py && \
    python2 -m pip install ipykernel && \
    python2 -m ipykernel install && \
    chown $NB_USER /usr/local/bin && \
    chown -R $NB_USER /usr/local/share && \
    chown -R $NB_USER /usr/local/lib && \
    chown -R $NB_USER /usr/local/lib/python2.7

WORKDIR /home/$NB_USER/work
USER $NB_USER

# Install Jupyter and Py3 packages
RUN mkdir -p ~/.pip/ && \
    pip install jupyter && \
    python2 -m pip install \
    scipy==0.18.1 \
    numpy==1.12.0 \
    scikit-learn==0.19.1 \
    patsy==0.4.1 \
    pandas==0.19.2 \
    theano==0.8.2 \
    keras==2.1.5 \
    xgboost==0.7.post4 \
    statsmodels==0.8.0 \
    tensorflow==1.2.0 \
    line_profiler==2.0 \
    orderedmultidict==0.7.11 \
    smhasher==0.150.1 \
    textblob==0.11.1 \
    h5py==2.8.0.rc1 \
    pudb==2017.1 \
    bokeh==0.12.4 \
    plotly==2.0.1 \
    lightgbm==2.1.0 \
    bunch==1.0.1 \
    gensim==3.4.0 \
    nltk==3.2.5 \
    textstat==0.4.1 \
    readability==0.2 \
    beautifulsoup4==4.6.0 \
    lxml==4.2.1 \
    jieba==0.39 \
    # k-lab plugin
    klab-autotime==0.0.2 && \
    jupyter nbextension install --user --py vega

# Install chinese fonts, set minus numbers available,  and set it as default(must be set after matplotlib installed), add tuna mirror pypi souce index
COPY MicrosoftYaHei.ttf /usr/local/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/
RUN echo 'font.family         : sans-serif' >> /usr/local/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    echo 'font.sans-serif     : Microsoft YaHei, DejaVu Sans, Bitstream Vera Sans, Lucida Grande, Verdana, Geneva, Lucid, Arial, Helvetica, Avant Garde, sans-serif' >> /usr/local/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    echo 'axes.unicode_minus  : False' >> /usr/local/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc

USER root
# Delete files that pip caches when installing a package.
RUN rm -rf /root/.cache/pip/* && \
    rm -rf /home/$NB_USER/.cache/pip/* && \
    # Delete old downloaded archive files
    apt-get autoremove -y && \
    # Delete downloaded archive files
    apt-get clean && \
    # Ensures the current working directory won't be deleted
    cd /usr/local/src/ && \
    # Delete source files used for building binaries
    rm -rf /usr/local/src/* && \
    # Delete matplotlib cache
    rm -rf /home/$NB_USER/.cache/matplotlib && \
