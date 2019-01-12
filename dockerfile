FROM jupyter/base-notebook
RUN pip install PyMySQL
RUN pip install boto3
