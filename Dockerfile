FROM node:14-bullseye
ENV NODE_ENV=development
RUN apt-get update && apt-get install -y android-sdk

ARG cmdline_tools=https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip
ARG android_home=/opt/android/sdk

# Download and install Android Commandline Tools
RUN mkdir -p ${android_home}/cmdline-tools && \
    wget -O /tmp/cmdline-tools.zip -t 5 "${cmdline_tools}" && \
    unzip -q /tmp/cmdline-tools.zip -d ${android_home}/cmdline-tools && \
    rm /tmp/cmdline-tools.zip

# deprecated upstream, should be removed in next-gen image
ENV ANDROID_HOME ${android_home}
ENV ANDROID_SDK_ROOT ${android_home}
ENV ADB_INSTALL_TIMEOUT 120
ENV PATH=${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

RUN mkdir ~/.android && echo '### User Sources for Android SDK Manager' > ~/.android/repositories.cfg

RUN yes | sdkmanager --licenses && yes | sdkmanager --update

# Update SDK manager and install system image, platform and build tools
# Platform tools will be installed manually outside of sdkmanager. This is due
# to an issue with the current latest version 31.0.3. We'll likely be able to
# undo this change in the near future.
RUN sdkmanager \
        "tools"    \
        "emulator"    &&    \
    cd /opt/android/sdk && \
    curl -sSL "https://dl.google.com/android/repository/platform-tools_r31.0.2-linux.zip" -o platform-tools.zip && \
    unzip -o platform-tools.zip && \
    rm platform-tools.zip

RUN sdkmanager "platforms;android-31"

WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install -g cordova@11.0.0
RUN npm install -g @ionic/cli
RUN npm install -g husky
RUN npm ci
#RUN npm install --production --silent && mv node_modules ../
COPY . .
EXPOSE 4200
#RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]
