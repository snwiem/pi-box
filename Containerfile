FROM node:22-alpine

LABEL org.opencontainers.image.description="pi-box base image — Node.js LTS + pi coding agent"

RUN npm install -g @earendil-works/pi-coding-agent && npm cache clean --force
