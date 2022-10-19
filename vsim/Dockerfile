FROM node:16-alpine as build-step
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY package.json yarn.lock ./
COPY ./src ./src
COPY ./public ./public
RUN yarn install
RUN yarn build

# Build 
FROM python:3.9
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir wrapt cantools prompt_toolkit python-can can-isotp matplotlib
WORKDIR /app
COPY --from=build-step /app/build ./build

RUN mkdir ./api
COPY api/requirements.txt api/api.py api/.flaskenv ./api
RUN pip install -r ./api/requirements.txt
ENV FLASK_ENV production

EXPOSE 3000
WORKDIR /app/api
CMD ["gunicorn", "-b", ":3000", "api:app"]
