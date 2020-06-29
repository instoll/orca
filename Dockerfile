# Step 1. Build ORCA and take PostgreSQL snapshot.
FROM ubuntu:18.04

# Disable interactive prompt during installation.
ENV DEBIAN_FRONTEND noninteractive

# Rootless user configurations.
ENV USER     orca
ENV USER_ID  1000
ENV GROUP_ID 1000
ENV HOMEDIR  /home/$USER

WORKDIR /tmp

# ORCA installation.
# https://www.orca.med.or.jp/receipt/download/bionic/bionic_install_51.html#receipt
RUN echo "Installing OS and ORCA dependencies" && \
      apt-get -y update && \
      apt-get install -y \
        init \
        gnupg \
        language-pack-ja \
        language-pack-ja-base \
        sudo \
        rsync \
        wget && \
    echo "Setting up user.." && \
      addgroup --gid $GROUP_ID $USER && \
      adduser -u $USER_ID --gid $GROUP_ID --gecos '' --home $HOMEDIR --disabled-password $USER && \
    echo "Installing dependencies.." && \
      apt-get update && \
      apt-get install -y sudo && \
    echo "Adding user to sudoer.. (development mode only)" && \
      adduser $USER sudo && \
      echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER && \
      echo "Set disable_coredump false" >> /etc/sudo.conf && \
    echo "Setting up locales" && \
      locale-gen ja_JP.UTF-8 && \
    echo "Setting up ORCA apt keyring" && \
      wget -q https://ftp.orca.med.or.jp/pub/ubuntu/archive.key && \
      apt-key add archive.key && \
      rm archive.key && \
    echo "Setting up ORCA apt-line" && \
      wget -q -O /etc/apt/sources.list.d/jma-receipt-bionic51.list https://ftp.orca.med.or.jp/pub/ubuntu/jma-receipt-bionic51.list && \
      apt-get -y update && \
      apt-get -y dist-upgrade && \
    echo "Installing ORCA and PushAPI" && \
      apt-get install -y \
        jma-receipt \
        jma-receipt-pusher \
        push-exchanger && \
    echo "Installing ORCA extra modules" && \
      wget http://ftp.orca.med.or.jp/pub/etc/install_modules_for_ftp.tgz && \
      tar xvzf install_modules_for_ftp.tgz && \
      cd install_modules_for_ftp && \
      sudo -u $USER ./install_modules.sh && \
    echo "Initializing ORCA" && \
      service postgresql start && \
      echo 'DBENCODING="UTF-8"' > /etc/jma-receipt/db.conf && \
      jma-setup && \
    echo "Snapshot ORCA database" && \
      sudo -u $USER pg_dump $USER > $HOMEDIR/db-snapshot.sql && \
      chown $USER:$USER $HOMEDIR/db-snapshot.sql && \
    echo "Cleanup" && \
      rm -Rf /tmp/*

# Locale and timezone configurations.
ENV LANG     ja_JP.utf8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL   ja_JP.utf8
ENV TZ       Asia/Tokyo

WORKDIR $HOMEDIR

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

