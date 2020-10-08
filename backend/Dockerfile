# Builder
FROM node:14-alpine as builder
# Copy files to build directory and navigate to build directory
COPY . /build
# Install dependencies and build app
RUN cd /build && yarn install --ignore-optional && yarn run build

FROM node:14-alpine

# Copy files
COPY --from=builder /build/build /app
# To app folder
WORKDIR /app
# Set NODE_ENV to production
ENV NODE_ENV production

# Install production dependencies
RUN yarn install --production --ignore-optional --frozen-lockfile && yarn cache clean

# Add user
# RUN adduser -D comp90018
# Switch user
# USER comp90018

# Specify port and start command
EXPOSE 3000
CMD [ "node", "server.js" ]
