# Base image
FROM ubuntu:22.04

# Labels and Credits
LABEL \
    name="MobSF" \
    author="Ajin Abraham <ajin25@gmail.com>" \
    maintainer="Ajin Abraham <ajin25@gmail.com>" \
    contributor_1="OscarAkaElvis <oscar.alfonso.diaz@gmail.com>" \
    contributor_2="Vincent Nadal <vincent.nadal@orange.fr>" \
    description="Mobile Security Framework (MobSF) is an automated, all-in-one mobile application (Android/iOS/Windows) pen-testing, malware analysis and security assessment framework capable of performing static and dynamic analysis."

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    MOBSF_USER=mobsf \
    USER_ID=9901 \
    MOBSF_PLATFORM=docker \
    MOBSF_ADB_BINARY=/usr/bin/adb \
    JDK_FILE=openjdk-20.0.2_linux-x64_bin.tar.gz \
    JDK_FILE_ARM=openjdk-20.0.2_linux-aarch64_bin.tar.gz \
    WKH_FILE=wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
    WKH_FILE_ARM=wkhtmltox_0.12.6.1-2.jammy_arm64.deb \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    POETRY_VERSION=1.6.1 \
    TZ="Etc/UTC"

# Install locales and generate locale
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Install necessary packages
RUN apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    sqlite3 \
    fontconfig-config \
    libjpeg-turbo8 \
    libxrender1 \
    libfontconfig1 \
    libxext6 \
    fontconfig \
    xfonts-75dpi \
    xfonts-base \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    curl \
    git \
    jq \
    unzip \
    android-tools-adb && \
    apt-get upgrade -y

# Install wkhtmltopdf & OpenJDK
ARG TARGETPLATFORM

# Copy source code
RUN mkdir -p /home/mobsf && cd /home/mobsf \
    && git clone https://github.com/MobSF/Mobile-Security-Framework-MobSF /home/mobsf/Mobile-Security-Framework-MobSF \
    && cd /home/mobsf/Mobile-Security-Framework-MobSF \
    && cp ./scripts/install_java_wkhtmltopdf.sh . \
    && ./install_java_wkhtmltopdf.sh 

# Update MobSF tools and apply patches
# APKTOOL latest version
RUN APKTOOL_URL=$(curl -s https://bitbucket.org/iBotPeaches/apktool/downloads/  | grep -oP 'href="\K(.*?apktool_[^"]*\.jar)' | head -n 1) \
    && curl -Lo /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/StaticAnalyzer/tools/apktool.jar https://bitbucket.org$APKTOOL_URL \
    && chmod +r /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/StaticAnalyzer/tools/apktool.jar

# JADX - Dex to Java Decompiler 
RUN JADX_VERSION=$(curl -s "https://api.github.com/repos/skylot/jadx/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+') \
    && curl -Lo jadx.zip "https://github.com/skylot/jadx/releases/latest/download/jadx-${JADX_VERSION}.zip" \
    && unzip jadx.zip -d jadx \
    && mv jadx /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/StaticAnalyzer/tools/jadx \
    && rm -rf jadx.zip

# Apply patches
COPY ./patches /tmp/patches
RUN sed -i "s/apktool_2.9.3.jar/apktool.jar/" /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/StaticAnalyzer/views/android/manifest_utils.py && \
    patch --binary /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/StaticAnalyzer/views/android/static_analyzer.py < /tmp/patches/static_analyzer.patch && \
    patch --binary /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/MobSF/views/api/api_static_analysis.py < /tmp/patches/api_static_analysis.patch && \
    patch --binary /home/mobsf/Mobile-Security-Framework-MobSF/mobsf/MobSF/urls.py < /tmp/patches/urls.patch

    
# Set JAVA_HOME
ENV JAVA_HOME=/home/mobsf/Mobile-Security-Framework-MobSF/jdk-20.0.2/

# Set working directory
WORKDIR /home/mobsf/Mobile-Security-Framework-MobSF

# Install Python dependencies
RUN python3 -m pip install --upgrade --no-cache-dir pip poetry==${POETRY_VERSION} && \
    poetry config virtualenvs.create false && \
    poetry install --only main --no-root --no-interaction --no-ansi

# Cleanup unnecessary packages
RUN apt-get remove -y \
        libssl-dev \
        libffi-dev \
        libxml2-dev \
        libxslt1-dev \
        python3-dev \
        wget && \
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* > /dev/null 2>&1

# Check if Postgres support needs to be enabled. Disabled by default
ARG POSTGRES=False

# Environment variables for Postgres
ENV POSTGRES_USER=postgres \
    POSTGRES_PASSWORD=password \
    POSTGRES_DB=mobsf \
    POSTGRES_HOST=postgres \
    DJANGO_SUPERUSER_USERNAME=mobsf \
    DJANGO_SUPERUSER_PASSWORD=mobsf

# Enable Postgres support if specified
RUN cd /home/mobsf/Mobile-Security-Framework-MobSF \
    && ./scripts/postgres_support.sh $POSTGRES

# Health check for the application
HEALTHCHECK CMD curl --fail http://host.docker.internal:8000/ || exit 1

# Expose application and proxy ports
EXPOSE 8000 8000 1337 1337

# Create mobsf user (commented out)
# RUN groupadd --gid $USER_ID $MOBSF_USER && \
#     useradd $MOBSF_USER --uid $USER_ID --gid $MOBSF_USER --shell /bin/false && \
#     chown -R $MOBSF_USER:$MOBSF_USER /home/mobsf
# USER $MOBSF_USER

# Update PATH for Java
ENV PATH="$JAVA_HOME/bin:$PATH"

# Run MobSF
CMD ["/home/mobsf/Mobile-Security-Framework-MobSF/scripts/entrypoint.sh"]
