FROM usgseros/lcmap-spark:1.0.1-develop

RUN  sudo /usr/local/bin/conda install scipy scikit-learn=0.18 --yes
RUN  mkdir -p firebird
COPY .test_env test.sh setup.py version.txt Makefile README.rst ./firebird/
COPY firebird firebird/firebird
COPY test firebird/test
COPY resources/log4j.properties $SPARK_HOME/conf/log4j.properties

RUN sudo chown -R lcmap:lcmap . && \
    sudo /usr/local/bin/pip install -e firebird/.[test,dev] && \
    sudo sh -c 'find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf' && \
    sudo yum clean all && \
    sudo rm -rf /var/cache/yum
