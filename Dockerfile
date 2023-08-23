# 指定 node 版本号，满足宿主环境
FROM node:16 as builder

# 指定工作目录，将代码添加至此
WORKDIR /code
ADD . /code

# 如何将项目跑起来
ADD package.json /code

RUN yarn install
RUN yarn run build
RUN yarn start
