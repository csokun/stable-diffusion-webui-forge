FROM nvidia/cuda:12.4.1-base-ubuntu22.04
ENV DEBIAN_FRONTEND noninteractive
ENV CMDARGS --listen

RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y curl wget libgl1 libglib2.0-0 python3-pip python-is-python3 git \
	ffmpeg libx264-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# perftools
RUN apt-get update && apt-get install --no-install-recommends -y google-perftools

COPY requirements_versions.txt requirements.txt /tmp/
RUN --mount=type=cache,target=/root/.cache \
	pip install -r /tmp/requirements_versions.txt -r /tmp/requirements.txt

RUN --mount=type=cache,target=/root/.cache \
	pip install -U xformers --index-url https://download.pytorch.org/whl/cu121

RUN curl -fsL -o /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2 https://cdn-media.huggingface.co/frpc-gradio-0.2/frpc_linux_amd64 && \
	chmod +x /usr/local/lib/python3.10/dist-packages/gradio/frpc_linux_amd64_v0.2

RUN adduser --disabled-password --gecos '' user && \
	mkdir -p /app /data /app/models /app/extensions

COPY entrypoint.sh /app/
RUN chown -R user:user /app

WORKDIR /app
USER user

COPY --chown=user:user . /app 

CMD [ "sh", "-c", "python launch.py ${CMDARGS}" ]