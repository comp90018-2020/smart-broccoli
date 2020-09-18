# Backend
![Build Backend](https://github.com/comp90018-2020/fuzzy-broccoli/workflows/Build%20Backend/badge.svg)

Backend server for app
Note: portions of code have been adapted from [COMP30022-Russia/COMP30022\_Server](https://github.com/COMP30022-Russia/COMP30022_Server)

## Installation
1. Build image: `docker-compose build`
2. Move `.env.sample` to `.env`, fill in environment variables
3. Start container: `docker-compose up -d`

## Environment variables
|Name|Default value|Description|
|:---|:---|:---|
|POSTGRES\_USER|comp90018|Postgres username|
|POSTGRES\_PASSWORD|(null)|Postgres password|
|POSTGRES\_DB|comp90018|Postgres database|
|POSTGRES\_HOST|postgresql|Postgres host (reflects `docker-compose.yml` service)|
|TOKEN\_SECRET|foo|Secret used to sign JWT tokens (authentication)
