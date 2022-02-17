FROM python:3.10-buster 
ENV PYTHONUNBUFFERED=1 
WORKDIR /src 

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  #
  # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME  

  
RUN pip install poetry 
# poetryでライブラリをインストール（pyproject.tomlが存在する場合）
COPY pyproject.toml* poetry.lock* ./
RUN poetry config virtualenvs.in-project true 
RUN if [ -f pyproject.toml ]; then poetry install; fi 


# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************
USER $USERNAME


ENTRYPOINT ["poetry", "run", "uvicorn", "api.main:app", "--host", "0.0.0.0", "--reload"]