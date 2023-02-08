FROM circleci/android:api-30-node
ENV NODE_ENV=development
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN sudo npm install -g cordova@11.0.0
RUN sudo npm install -g @ionic/cli
RUN sudo npm install -g husky
#RUN npm install --production --silent && mv node_modules ../
COPY . .
RUN chown -R node /usr/src/app
USER node
CMD ["npm", "start"]
