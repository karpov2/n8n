FROM node:20-alpine

# Увеличиваем хип до 4GB (достаточно для сборки и работы)
ENV NODE_OPTIONS="--max-old-space-size=4096" \
    DOCKER_BUILD=true \
    N8N_SKIP_LICENSE_CHECK=true

WORKDIR /usr/src/app

# Установка инструментов (git для клона, python3/g++ для сборки, psql – для доступа к БД)
RUN apk add --no-cache bash git python3 make g++ postgresql-client \
 && npm install -g pnpm

# Копируем весь репозиторий и собираем
COPY . .
RUN pnpm install --frozen-lockfile \
 && pnpm run build

# Делаем bin-скрипт исполняемым
RUN sed -i 's/\r$//' packages/cli/bin/n8n \
 && chmod +x packages/cli/bin/n8n \
 && ln -s /usr/src/app/packages/cli/bin/n8n /usr/local/bin/n8n

EXPOSE 5678

ENTRYPOINT ["n8n"]
CMD ["start"]
