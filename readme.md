# Spring Boot Todo App

A simple **Todo backend** built with **Spring Boot**, **PostgreSQL**, and **Docker Compose**.  
It provides REST APIs for creating and managing tasks.

---

## Tech Stack

- **Java 17+**
- **Spring Boot**
  - Spring Web
  - Spring Data JPA
- **PostgreSQL 17**
- **Docker / Docker Compose**
- **Maven**

---

## Getting Started

### 1. create external network & volume on first run

```bash
docker network create todo-net
```

```bash
docker volume create postgres-data
```

### 2. Build with docker compose

```bash
docker build -t todo-backend . 
```
(remember the dot)

```bash
docker compose up -d
```

Show docker logs

```bash
docker compose logs -f todo-backend
```

### 3. Run backend locally for hot reload:

#### 1. start database in docker container

```bash
docker compose up todo-db -d
```

#### 2. in a new terminal:

```bash
.\mvnw spring-boot:run
```

### 4. Mock data

Mock Insert Task:

```bash
wget http://localhost:8080/api/tasks/mock -Method POST
```

Get tasks:

```bash
wget http://localhost:8080/api/tasks/ -Method GET
```

or just visit `http://localhost:8080/api/tasks`
