FROM debian
RUN apt update
RUN curl -sSL https://get.easypanel.io | sh
EXPOSE 8900
