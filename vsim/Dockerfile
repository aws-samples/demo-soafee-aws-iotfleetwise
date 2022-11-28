FROM public.ecr.aws/docker/library/node:18 as build-step
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json yarn.lock ./
COPY ./src ./src
COPY ./public ./public
RUN yarn install
RUN yarn build

# Build 
FROM public.ecr.aws/docker/library/python:3.9

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    git ca-certificates iproute2 && \
    apt-get clean

WORKDIR /app
COPY --from=build-step /app/build ./build

RUN mkdir ./api
COPY api/requirements.txt api/api.py api/.flaskenv api/canigen.py api/mymodel.dbc api/start-api.sh ./api/
RUN pip install -r ./api/requirements.txt 
ENV FLASK_ENV production

EXPOSE 3000
WORKDIR /app/api
CMD ["/bin/bash", "start-api.sh"]
